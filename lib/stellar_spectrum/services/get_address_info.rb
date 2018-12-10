module StellarSpectrum
  class GetAddressInfo

    extend LightService::Action
    expects :locked_accounts, :address
    promises :address_info, :unlock_response

    executed do |c|
      c.address_info = c.locked_accounts[c.address]

      c.unlock_response = nil
      next c if c.address_info.present?

      c.unlock_response = true

      message = "#{c.address} has been unlocked by some other mechanism like " \
        "ttl expiration or by something else, so this is a success"
      c.skip_remaining!(message)
    end

  end
end
