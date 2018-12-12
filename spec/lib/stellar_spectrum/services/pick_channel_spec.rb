require 'spec_helper'

module StellarSpectrum
  RSpec.describe PickChannel do

    let(:available_channels) { 5.times.map { Stellar::Account.random } }
    let(:transaction_source) { Stellar::Account.random }

    it "picks one from the available_channels" do
      result = described_class.execute(
        available_channels: available_channels,
        transaction_source: nil,
      )
      expect(available_channels).to include result.channel_account
    end

  end
end
