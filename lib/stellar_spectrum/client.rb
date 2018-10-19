module StellarSpectrum
  class Client

    attr_accessor :redis_url
    attr_accessor :seeds
    attr_accessor :horizon_url
    attr_accessor :logger

    LOG_TAG = "[StellarSpectrum]"
    MAX_LOCK_TIME_IN_SECONDS = 30

    def initialize(
      redis_url: StellarSpectrum.configuration.redis_url,
      seeds: StellarSpectrum.configuration.seeds,
      horizon_url: StellarSpectrum.configuration.horizon_url,
      logger: StellarSpectrum.configuration.logger
    )
      self.redis_url = redis_url
      self.seeds = seeds
      self.horizon_url = horizon_url
      self.logger = logger
    end

    def send_payment(from:, to:, amount:, memo: nil, tries: 0)
      tries += 1
      available_channels = GetAvailableChannels.execute(
        redis: redis,
        locked_accounts: locked_accounts,
        channel_accounts: channel_accounts,
      )

      if available_channels.empty?
        log "No available channels, retry for the #{tries.ordinalize} time..."
        attempt_release_lock!

        return send_payment(
          from: from,
          to: to,
          amount: amount,
          memo: memo,
          tries: tries,
        )
      end

      log "Sending payment. #{available_channels.count} available channels: " \
        "#{available_channels.map(&:address).inspect}"

      channel_account = available_channels.first

      next_sequence_number = next_sequence_number_for(channel_account)

      successfully_locked = lock!(channel_account.address, {
        sequence_number: next_sequence_number,
      })

      if !successfully_locked
        log "Unable to lock #{channel_account.address}, " \
          "retry for the #{tries.ordinalize} time..."

        attempt_release_lock!

        return send_payment(
          from: from,
          to: to,
          amount: amount,
          memo: memo,
          tries: tries,
        )
      end

      stellar_client.send_payment(
        from: from,
        to: to,
        amount: amount,
        memo: memo,
        channel_account: channel_account,
        sequence: next_sequence_number,
      )
    end

    def attempt_release_lock!(except_address: nil)
      if logger
        log_message =  "Attempting to release a lock"
        if except_address.present?
          log_message << "(except for address #{except_address})"
        end
        log log_message
      end

      address, address_info = locked_accounts.except(except_address).
        sort_by {|address, info| info[:pttl]}.last

      return false if address.nil?

      current_sequence_number = current_sequence_number_for(address)
      address_info = locked_accounts[address]

      # Someone else may have unlocked it while we were taking our sweet
      # time fetching the sequence number
      return false if address_info.nil?

      address_sequence_number = address_info[:sequence_number].to_i
      if current_sequence_number < address_sequence_number
        log "Not releasing #{address}: sequence number locked at " \
          "#{address_sequence_number} is > current sequence number " \
          "#{current_sequence_number}"
        return false
      end

      log "Releasing #{address}: sequence number locked at " \
        "#{address_sequence_number} is <= current sequence number " \
        "#{current_sequence_number}"
      unlock!(address)
    end

    def channel_accounts
      @channel_accounts ||= seeds.map { |s| Stellar::Account.from_seed(s) }
    end

    def locked_accounts
      GetLockedAccounts.execute(redis: redis, channel_accounts: channel_accounts)
    end

    def stellar_client
      @stellar_client ||= Stellar::Client.new(horizon: self.horizon_url)
    end

    def redis
      @redis ||= InitRedis.execute(redis_url: self.redis_url)
    end

    def lock!(address, sequence_number:)
      redis.set(GetKeyForAddress.execute(address), sequence_number, {
        nx: true,
        ex: MAX_LOCK_TIME_IN_SECONDS,
      })
    end

    def unlock!(address)
      log "Unlocking address #{address}"
      redis.del(GetKeyForAddress.execute(address))
    end

    def next_sequence_number_for(address_or_account)
      current_sequence_number_for(address_or_account) + 1
    end

    def current_sequence_number_for(address_or_account)
      account = address_or_account
      if address_or_account.is_a?(String)
        account = Stellar::Account.from_address(address_or_account)
      end

      stellar_client.account_info(account).sequence.to_i
    end

    def log(message)
      return if logger.nil?
      logger.info [LOG_TAG, message].join(" ")
    end

  end
end
