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
      horizon_url:,
      force_transaction_source: nil,
      force_sequence_number: nil,
      force_lock: false
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
        force_transaction_source: force_transaction_source,
        force_sequence_number: force_sequence_number,
        force_lock: force_lock,
      ).reduce(actions)
    end

    def self.actions
      [
        IncrementTries,
        InitStellarClient,
        InitRedis,
        GetChannelAccounts,
        reduce_if(->(c) {c[:force_transaction_source].nil?}, [
          GetLockedAccounts,
          GetAvailableChannels,
          reduce_if(->(c) {c.available_channels.empty?}, SendingPayment::Retry),
          PickChannel,
        ]),
        reduce_if(->(c) {c[:force_transaction_source].present?}, [
          execute(->(c) {c[:channel_account] = c[:force_transaction_source]}),
        ]),
        GetSequenceNumber,
        LockChannel,
        reduce_if(->(c) {!c.successfully_locked}, SendingPayment::Retry),
        SendingPayment::SendAsset,
        Unlock,
      ]
    end

  end
end
