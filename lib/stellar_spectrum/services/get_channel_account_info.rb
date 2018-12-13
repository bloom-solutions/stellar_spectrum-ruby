module StellarSpectrum
  class GetChannelAccountInfo

    extend LightService::Action
    expects :locked_accounts, :channel_account
    promises :channel_account_info, :unlock_response

    executed do |c|
      c.channel_account_info = c.locked_accounts[c.channel_account.address]

      c.unlock_response = nil
      next c if c.channel_account_info.present?

      c.unlock_response = true

      message = "#{c.channel_account.address} has been unlocked by some " \
        "other mechanism like ttl expiration or by something else, " \
        "so this is a success"
      c.skip_remaining!(message)
    end

  end
end
