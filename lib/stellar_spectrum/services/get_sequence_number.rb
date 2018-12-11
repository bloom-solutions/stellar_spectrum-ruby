module StellarSpectrum
  class GetSequenceNumber

    extend LightService::Action
    expects :stellar_client, :channel_account, :sequence_number
    promises :sequence_number

    executed do |c|
      next c if c.sequence_number.present?

      account_info = c.stellar_client.account_info(c.channel_account)
      c.sequence_number = account_info.sequence.to_i
    end

  end
end
