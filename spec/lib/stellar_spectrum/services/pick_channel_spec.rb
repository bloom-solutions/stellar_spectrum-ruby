require 'spec_helper'

module StellarSpectrum
  RSpec.describe PickChannel do

    let(:available_channels) { 5.times.map { Stellar::Account.random } }
    let(:transaction_source) { Stellar::Account.random }

    context "no transaction_source is given" do
      it "picks one from the available_channels" do
        result = described_class.execute(
          available_channels: available_channels,
          transaction_source: nil,
        )
        expect(available_channels).to include result.channel_account
      end
    end

    context "a transaction_source is given" do
      it "picks the transaction_source" do
        result = described_class.execute(
          available_channels: available_channels,
          transaction_source: transaction_source,
        )
        expect(result.channel_account).to eq transaction_source
      end
    end

  end
end
