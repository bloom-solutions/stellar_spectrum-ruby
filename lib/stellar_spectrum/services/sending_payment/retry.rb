module StellarSpectrum
  module SendingPayment
    class Retry

      extend LightService::Action
      EXPECTS = %i[
        from
        to
        amount
        memo
        tries
        seeds
        horizon_url
        redis_url
        force_transaction_source
        force_sequence_number
      ]
      expects *EXPECTS
      promises :send_asset_response

      executed do |c|
        args = EXPECTS.each_with_object({}) do |attr, hash|
          hash[attr] = c.send(attr)
        end

        c.send_asset_response = SendPayment.(args).send_asset_response

        # THIS IS IMPORTANT or else it will continue with the rest of the
        # actions and possibly send out the asset just as many times as `tries`
        # https://github.com/adomokos/light-service/pull/164
        # fail_and_return for now until we figure out a way to stop all actions
        # from reduce_if
        # See https://github.com/adomokos/light-service/pull/164
        message = "Closing try #{c.tries} (#{Thread.current})"
        c.fail_and_return! message
      end

    end

  end
end
