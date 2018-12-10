module StellarSpectrum
  class GetAvailableChannels

    extend LightService::Action
    expects :redis, :locked_accounts, :channel_accounts
    promises :available_channels

    executed do |c|
      locked_addresses = c.locked_accounts.keys

      c.available_channels = c.channel_accounts.each_with_object([]) do |account, channels|
        next if locked_addresses.include?(account.address)
        channels << account
      end
    end

  end
end
