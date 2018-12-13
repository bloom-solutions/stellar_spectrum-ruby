module StellarSpectrum
  module Unlocking
    class Unlock

      extend LightService::Action
      expects :redis, :channel_account
      promises :unlock_response

      executed do |c|
        address_key = GetKeyForAddress.execute(c.channel_account.address)
        puts "Will unlock #{address_key}"
        c.unlock_response = c.redis.del(address_key)
      end

    end
  end
end
