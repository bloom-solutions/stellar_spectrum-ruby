module StellarSpectrum
  class LockChannel

    extend LightService::Action
    expects :channel_account, :sequence_number, :redis
    promises :successfully_locked

    executed do |c|
      address = c.channel_account.address
      address_key = GetKeyForAddress.execute(address)
      next_sequence_number = c.sequence_number + 1

      c.successfully_locked = c.redis.set(address_key, next_sequence_number, {
        nx: true,
        ex: Client::MAX_LOCK_TIME_IN_SECONDS,
      })
    end

  end
end
