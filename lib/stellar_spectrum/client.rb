module StellarSpectrum
  class Client

    attr_accessor :redis_url
    attr_accessor :seeds
    attr_accessor :horizon_url
    attr_accessor :logger

    LOG_TAG = "[StellarSpectrum]"
    MAX_LOCK_TIME_IN_SECONDS = 30

    def initialize(
      redis_url: StellarSpectrum.configuration.redis_url,
      seeds: StellarSpectrum.configuration.seeds,
      horizon_url: StellarSpectrum.configuration.horizon_url,
      logger: StellarSpectrum.configuration.logger
    )
      self.redis_url = redis_url
      self.seeds = seeds
      self.horizon_url = horizon_url
      self.logger = logger
    end

    def send_payment(from:, to:, amount:, memo: nil, tries: 0)
      result = SendPayment.(
        from: from,
        to: to,
        amount: amount,
        memo: memo,
        seeds: seeds,
        redis_url: redis_url,
        horizon_url: horizon_url,
      )

      # if result.failure?
        # return false
      # end

      result.send_asset_response
    end
  end
end
