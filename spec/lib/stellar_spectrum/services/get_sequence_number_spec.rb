require 'spec_helper'

module StellarSpectrum
  RSpec.describe GetSequenceNumber do

    let(:stellar_client) do
      InitStellarClient.execute(horizon_url: CONFIG[:horizon_url])
        .stellar_client
    end
    let(:channel_account) { Stellar::Account.from_seed(CONFIG[:sender_seed]) }

    context "sequence_number is nil in the context" do
      it "fetches the sequence_number from horizon", vcr: {record: :once} do
        result = described_class.execute(
          stellar_client: stellar_client,
          channel_account: channel_account,
          sequence_number: nil,
        )
        expect(result.sequence_number).to be_an Integer
        expect(result.sequence_number).to be > 0
      end
    end

    context "sequence_number is not nil in the context" do
      it "is the sequence_number in the context" do
        result = described_class.execute(
          stellar_client: stellar_client,
          channel_account: channel_account,
          sequence_number: 22,
        )
        expect(result.sequence_number).to eq 22
      end
    end

  end
end
