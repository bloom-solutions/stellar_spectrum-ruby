module StellarSpectrum
  module Unlocking
    class GetAddressToUnlock

      extend LightService::Action
      expects :except_address, :locked_accounts
      promises :address

      executed do |c|
        c.address, info = c.locked_accounts.except(c.except_address)
          .sort_by {|address, info| info[:pttl]}.last

        next c if c.address.present?

        c.fail_and_return! "No addresses to unlock"
      end

    end
  end
end
