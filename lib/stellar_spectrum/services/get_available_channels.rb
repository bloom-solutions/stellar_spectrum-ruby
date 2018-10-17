module StellarSpectrum
  class GetAvailableChannels

    def self.execute(redis:, locked_accounts:, channel_accounts:)
      locked_addresses = locked_accounts.keys
      channel_accounts.each_with_object([]) do |account, available_channels|
        next if locked_addresses.include?(account.address)
        available_channels << account
      end
    end

  end
end
