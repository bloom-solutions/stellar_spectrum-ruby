module StellarSpectrum
  class InitRedis

    def self.execute(redis_url:)
      Redis.new(redis_url: redis_url)
    end

  end
end
