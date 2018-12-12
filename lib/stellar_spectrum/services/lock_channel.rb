module StellarSpectrum
  class LockChannel

    extend LightService::Action
    expects :channel_account, :next_sequence_number, :redis, :force_lock
    promises :successfully_locked

    SUCCESS_NON_NX_RESULT = "OK".freeze

    executed do |c|
      address = c.channel_account.address
      address_key = GetKeyForAddress.execute(address)

      c.successfully_locked = c.redis.set(address_key, c.next_sequence_number, {
        nx: !c.force_lock,
        ex: Client::MAX_LOCK_TIME_IN_SECONDS,
      })

      if c.successfully_locked == SUCCESS_NON_NX_RESULT
        c.successfully_locked = true
      end
    end

  end
end
