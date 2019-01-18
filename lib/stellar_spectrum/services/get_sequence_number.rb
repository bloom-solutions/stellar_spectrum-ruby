module StellarSpectrum
  class GetSequenceNumber

    extend LightService::Action
    expects :stellar_client, :channel_account
    promises :current_sequence_number, :next_sequence_number

    executed do |c|
      c.current_sequence_number = GetCurrentSequenceNumber.execute(
        stellar_client: c.stellar_client, 
        channel_account: c.channel_account
      )

      c.next_sequence_number = c[:force_sequence_number] ||
        c.current_sequence_number + 1
    end

  end
end
