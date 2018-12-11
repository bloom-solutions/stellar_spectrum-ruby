module StellarSpectrum
  class GetSequenceNumber

    extend LightService::Action
    expects :stellar_client, :channel_account
    promises :current_sequence_number, :next_sequence_number

    executed do |c|
      account_info = c.stellar_client.account_info(c.channel_account)
      c.current_sequence_number = account_info.sequence.to_i

      c.next_sequence_number = c[:force_sequence_number] ||
        c.current_sequence_number + 1
    end

  end
end
