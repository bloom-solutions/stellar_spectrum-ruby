module StellarSpectrum
  class PickChannel

    extend LightService::Action
    expects :available_channels
    promises :channel_account

    executed do |c|
      c.channel_account = c.available_channels.first
    end

  end
end
