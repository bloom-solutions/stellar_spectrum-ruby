module StellarSpectrum
  class GetLockedAccounts

    REDIS_PTTL_KEY_NON_PRESENT = -2

    def self.execute(redis:, channel_accounts:)
      addresses = channel_accounts.map(&:address)
      address_keys = addresses.map {|a| GetKeyForAddress.execute(a) }
      redis_response = redis.multi do
        redis.mget(*address_keys)
        address_keys.each do |key|
          redis.pttl key
        end
      end
      address_sequence_numbers = redis_response[0]
      address_pttls = redis_response[1..-1]

      addresses.each_with_object({}).with_index do |(address, hash), i|
        pttl = address_pttls[i]

        next if pttl == REDIS_PTTL_KEY_NON_PRESENT

        sequence_number = address_sequence_numbers[i]
        hash[address] = {sequence_number: sequence_number, pttl: pttl}
      end
    end

  end
end
