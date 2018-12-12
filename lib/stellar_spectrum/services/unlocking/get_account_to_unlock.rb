module StellarSpectrum
  module Unlocking
    class GetAccountToUnlock

      extend LightService::Action
      expects :locked_accounts
      promises :channel_account

      executed do |c|
        address, info = c.locked_accounts.except(c[:except_address])
          .sort_by {|address, info| info[:pttl]}.last

        if address.present?
          c.channel_account = Stellar::Account.from_address(address)
        else
          c.channel_account = nil
          c.fail_and_return! "No addresses to unlock"
        end
      end

    end
  end
end
