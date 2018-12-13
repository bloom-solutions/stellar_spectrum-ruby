module StellarSpectrum
  module Unlocking
    class AttemptRelease

      WAIT_TIME_IN_SECONDS = 5

      extend LightService::Organizer
      def self.call(redis:, channel_accounts:, channel_account:, stellar_client:)
        result = with(
          stellar_client: stellar_client,
          redis: redis,
          channel_account: channel_account,
          channel_accounts: channel_accounts,
        ).reduce(actions)

        if result.failure?
          sleep WAIT_TIME_IN_SECONDS
          result = self.(
            stellar_client: stellar_client,
            redis: redis,
            channel_account: channel_account,
            channel_accounts: channel_accounts,
          )
        end

        result
      end

      def self.actions
        [
          GetLockedAccounts,
          GetChannelAccountInfo,
          GetSequenceNumber,
          CheckSequenceNumber,
          Unlock,
        ]
      end

    end
  end
end
