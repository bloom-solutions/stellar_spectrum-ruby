module StellarSpectrum
  class SendPayment

    extend LightService::Organizer

    def self.call(
      from:,
      to:,
      amount:,
      memo: nil,
      tries: 0,
      seeds:,
      redis_url:,
      horizon_url: 
    )
      with(
        from: from,
        to: to,
        amount: amount,
        memo: memo,
        tries: tries,
        seeds: seeds,
        redis_url: redis_url,
        horizon_url: horizon_url,
      ).reduce(actions)
    end

    def self.actions
      [
        IncrementTries,
        InitStellarClient,
        InitRedis,
        GetChannelAccounts,
        GetLockedAccounts,
        GetAvailableChannels,
        reduce_if(->(c) { c.available_channels.empty? }, retry_actions),
        PickChannel,
        GetSequenceNumber,
        LockChannel,
        reduce_if(->(c) {!c.successfully_locked}, retry_actions),
        SendingPayment::SendAsset,
      ]
    end

    def self.retry_actions
      [
        SendingPayment::AttemptReleaseLock,
        SendingPayment::Retry,
      ]
    end

  end
end
