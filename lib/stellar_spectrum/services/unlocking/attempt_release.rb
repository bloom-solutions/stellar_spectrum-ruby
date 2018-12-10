module StellarSpectrum
  module Unlocking
    class AttemptRelease

      extend LightService::Organizer
      def self.call(redis:, channel_accounts:, except_address:, horizon_url:)
        result = with(
          horizon_url: horizon_url,
          redis: redis,
          channel_accounts: channel_accounts,
          except_address: except_address,
        ).reduce(actions)

        if result.failure?
          result[:unlock_response] = false
        end

        result
      end

      def self.actions
        [
          InitStellarClient,
          GetLockedAccounts,
          GetAddressToUnlock,
          GetSequenceNumber,
          # Someone else may have unlocked it while we were taking
          # our sweet time fetching the sequence number, so fetch
          # the locked accounts again:
          GetLockedAccounts,
          GetAddressInfo,
          CheckSequenceNumber,
          Unlock,
        ]
      end

    end
  end
end
