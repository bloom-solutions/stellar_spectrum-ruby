module StellarSpectrum
  module Unlocking
    class AttemptRelease

      extend LightService::Organizer
      def self.call(redis:, channel_accounts:, stellar_client:)
        result = with(
          stellar_client: stellar_client,
          redis: redis,
          channel_accounts: channel_accounts,
        ).reduce(actions)

        if result.failure?
          result[:unlock_response] = false
        end

        result
      end

      def self.actions
        [
          GetLockedAccounts,
          GetAccountToUnlock,
          GetSequenceNumber,
          # Someone else may have unlocked it while we were taking
          # our sweet time fetching the sequence number, so fetch
          # the locked accounts again:
          GetLockedAccounts,
          GetChannelAccountInfo,
          CheckSequenceNumber,
          Unlock,
        ]
      end

    end
  end
end
