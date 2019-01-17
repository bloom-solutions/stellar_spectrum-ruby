module StellarSpectrum
  module SendingPayment
    class SendAsset

      extend LightService::Action

      expects *%i[
        from
        to
        amount
        memo
        channel_account
        next_sequence_number
        stellar_client
        tries
        seeds
        horizon_url
        redis_url
      ]

      promises :send_asset_response

      executed do |c|
        c.send_asset_response = c.stellar_client.send_payment(
          from: c.from,
          to: c.to,
          amount: c.amount,
          memo: c.memo,
          transaction_source: c.channel_account,
          sequence: c.next_sequence_number,
        )
      rescue Faraday::ClientError => e
        retry_result = Retry.execute(
          stellar_client: c.stellar_client,
          from: c.from,
          to: c.to,
          amount: c.amount,
          memo: c.memo,
          tries: c.tries,
          seeds: c.seeds,
          horizon_url: c.horizon_url,
          redis_url: c.redis_url,
          force_transaction_source: c.channel_account,
          force_sequence_number: c.next_sequence_number,
          force_lock: true,
        )
        c.send_asset_response = retry_result[:send_asset_response]
      end

    end
  end
end
