module StellarSpectrum
  module Unlocking
    class Unlock

      extend LightService::Action
      expects :redis, :address
      promises :unlock_response

      executed do |c|
        address_key = GetKeyForAddress.execute(c.address)
        c.unlock_response = c.redis.del(address_key)
      end

    end
  end
end
