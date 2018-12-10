module StellarSpectrum
  class InitStellarClient

    extend LightService::Action
    expects :horizon_url
    promises :stellar_client

    executed do |c|
      c.stellar_client = Stellar::Client.new(c.horizon_url)
    end

  end
end
