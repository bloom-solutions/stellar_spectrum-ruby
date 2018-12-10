module StellarSpectrum
  class IncrementTries

    extend LightService::Action
    expects :tries
    promises :tries

    executed do |c|
      c.tries += 1
    end

  end
end
