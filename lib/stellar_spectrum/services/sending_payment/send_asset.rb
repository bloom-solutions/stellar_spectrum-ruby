module StellarSpectrum
  module SendingPayment
    class SendAsset

      extend LightService::Action
      TIMEOUT_CODE = 504.freeze

      expects *%i[
        from
        to
        amount
        memo
        channel_account
        next_sequence_number
        stellar_client
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
        if e.response[:status] == TIMEOUT_CODE
          retry_result = Retry.execute(
            stellar_client: c.stellar_client,
            from: c.from,
            to: c.to,
            amount: c.amount,
            memo: c.memo,
            force_transaction_source: c.channel_account,
            force_sequence_number: c.next_sequence_number,
          )
          c.send_asset_response = retry_result[:send_asset_response]
        else
          fail
        end
      end

    end
  end
end
