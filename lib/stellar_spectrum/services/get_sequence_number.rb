module StellarSpectrum
  class GetSequenceNumber

    extend LightService::Action
    expects :stellar_client, :address
    promises :sequence_number

    executed do |c|
      account = Stellar::Account.from_address(c.address)
      account_info = c.stellar_client.account_info(account)
      c.sequence_number = account_info.sequence.to_i
    end

  end
end
