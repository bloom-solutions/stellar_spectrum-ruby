module StellarSpectrum
  class GetSequenceNumber

    extend LightService::Action
    expects :stellar_client, :channel_account
    promises :sequence_number

    executed do |c|
      account_info = c.stellar_client.account_info(c.channel_account)
      c.sequence_number = account_info.sequence.to_i
    end

  end
end
