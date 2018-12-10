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
        sequence_number
        stellar_client
      ]

      promises :send_asset_response

      executed do |c|
        next_sequence_number = c.sequence_number + 1

        c.send_asset_response = c.stellar_client.send_payment(
          from: c.from,
          to: c.to,
          amount: c.amount,
          memo: c.memo,
          transaction_source: c.channel_account,
          sequence: next_sequence_number,
        )
      end

    end
  end
end
