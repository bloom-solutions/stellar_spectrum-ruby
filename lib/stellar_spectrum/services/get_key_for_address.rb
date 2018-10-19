module StellarSpectrum
  class GetKeyForAddress

    REDIS_PREFIX = "stellar_spectrum"

    def self.execute(address)
      "#{REDIS_PREFIX}:#{address}"
    end

  end
end
