require 'spec_helper'

module StellarSpectrum
  RSpec.describe GetSequenceNumber do

    let(:stellar_client) do
      InitStellarClient.execute(horizon_url: CONFIG[:horizon_url])
        .stellar_client
    end
    let(:channel_account) { Stellar::Account.from_seed(CONFIG[:sender_seed]) }
    let(:current_sequence_number) do
      stellar_client.account_info(channel_account).sequence.to_i
    end

    context "force_sequence_number is nil in the context" do
      it("sets the current and next sequence numbers", {
        vcr: {record: :once},
      }) do
        result = described_class.execute(
          stellar_client: stellar_client,
          channel_account: channel_account,
          force_sequence_number: nil,
        )
        expect(result.current_sequence_number).to eq current_sequence_number
        expect(result.next_sequence_number).to eq current_sequence_number+1
      end
    end

    context "sequence_number is not nil in the context" do
      it(
        "is the current_sequence_number to the current sequence_number, " \
        "and next_sequence_number to forced_sequence_number",
        { vcr: {record: :once} }
      ) do
        result = described_class.execute(
          stellar_client: stellar_client,
          channel_account: channel_account,
          force_sequence_number: 22,
        )
        expect(result.current_sequence_number).to eq current_sequence_number
        expect(result.next_sequence_number).to eq 22
      end
    end

  end
end
