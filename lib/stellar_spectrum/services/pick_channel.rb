module StellarSpectrum
  class PickChannel

    extend LightService::Action
    expects :available_channels, :transaction_source
    promises :channel_account

    executed do |c|
      c.channel_account = c.transaction_source || c.available_channels.first
    end

  end
end
