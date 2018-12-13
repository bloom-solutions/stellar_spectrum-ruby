module StellarSpectrum
  module Unlocking
    class CheckSequenceNumber

      extend LightService::Action
      expects :current_sequence_number, :channel_account, :channel_account_info

      executed do |c|
        address_sequence_number = c.channel_account_info[:sequence_number].to_i
        current_sequence_number = c.current_sequence_number

        next c if current_sequence_number >= address_sequence_number

        address = c.channel_account.address

        message = "Not releasing #{address}: sequence number locked at " \
          "#{address_sequence_number} is > current sequence number " \
          "#{current_sequence_number}"

        c.fail_and_return! message
      end

    end
  end
end
