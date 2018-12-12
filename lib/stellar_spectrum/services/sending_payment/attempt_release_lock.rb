module StellarSpectrum
  module SendingPayment
    class AttemptReleaseLock

      extend LightService::Action
      expects :stellar_client, :redis, :channel_accounts

      executed do |c|
        Unlocking::AttemptRelease.(
          stellar_client: c.stellar_client,
          redis: c.redis,
          channel_accounts: c.channel_accounts,
        )
      end

    end
  end
end
