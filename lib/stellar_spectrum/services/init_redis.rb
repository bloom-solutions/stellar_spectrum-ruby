module StellarSpectrum
  class InitRedis

    extend LightService::Action
    expects :redis_url
    promises :redis

    executed do |c|
      c.redis = Redis.new(redis_url: c.redis_url)
    end

  end
end
