module StellarSpectrum
  module Unlocking
    class Unlock

      extend LightService::Action
      expects :redis, :channel_account
      promises :unlock_response

      executed do |c|
        StellarSpectrum.configuration.logger "Unlocking #{c.channel_account.address}"
        address_key = GetKeyForAddress.execute(c.channel_account.address)
        c.unlock_response = c.redis.del(address_key)
      end

    end
  end
end
