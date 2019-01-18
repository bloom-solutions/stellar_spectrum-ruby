module StellarSpectrum
  class GetCurrentSequenceNumber

    def self.execute(stellar_client:, channel_account:)
      account_info = stellar_client.account_info(channel_account)
      account_info.sequence.to_i
    rescue Faraday::ClientError => e
      Log.warn("Retrying GetCurrentSequenceNumber - #{e.inspect}")
      execute(stellar_client: stellar_client, channel_account: channel_account)
    end

  end
end
