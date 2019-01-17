require 'spec_helper'

module StellarSpectrum
  module SendingPayment
    RSpec.describe SendAsset do

      let(:stellar_client) do
        InitStellarClient
          .execute(horizon_url: CONFIG[:horizon_url])
          .stellar_client
      end

      context "successful response" do
        let(:from) { Stellar::Account.from_seed(CONFIG[:sender_seed]) }
        let(:to) { Stellar::Account.from_address(CONFIG[:destination_address]) }
        let(:amount) { Stellar::Amount.new(1) }
        let(:channel_account) do
          Stellar::Account.from_seed(CONFIG[:payment_channel_seeds].first)
        end
        let(:next_sequence_number) do
          GetSequenceNumber.execute({
            stellar_client: stellar_client,
            channel_account: channel_account,
          }).next_sequence_number
        end
        let(:seeds) do
          CONFIG[:payment_channel_seeds].map do |seed|
            Stellar::Account.from_seed(seed)
          end
        end

        it "sends out the asset", vcr: {record: :once} do
          expect(stellar_client).to receive(:send_payment).with(
            from: from,
            to: to,
            amount: amount,
            memo: "abc",
            transaction_source: channel_account,
            sequence: next_sequence_number,
          ).and_call_original

          result = described_class.execute(
            stellar_client: stellar_client,
            from: from,
            to: to,
            amount: amount,
            memo: "abc",
            channel_account: channel_account,
            next_sequence_number: next_sequence_number,
            tries: 2,
            seeds: seeds,
            horizon_url: CONFIG[:horizon_url],
            redis_url: CONFIG[:redis_url],
          )

          expect(result.send_asset_response._success?).to be true
        end
      end

      context "timeout response" do
        let(:from) { Stellar::Account.from_seed(CONFIG[:sender_seed]) }
        let(:to) { Stellar::Account.from_address(CONFIG[:destination_address]) }
        let(:amount) { Stellar::Amount.new(1) }
        let(:channel_account) do
          Stellar::Account.from_seed(CONFIG[:payment_channel_seeds].sample)
        end
        let(:seeds) do
          CONFIG[:payment_channel_seeds].map do |seed|
            Stellar::Account.from_seed(seed)
          end
        end
        let(:timeout_error) do
          Faraday::ClientError.new(nil, {status: 504})
        end
        let(:retried_send_asset_response) do
          instance_double(Hyperclient::Resource)
        end
        let(:retried_ctx) do
          LightService::Context.new({
            send_asset_response: retried_send_asset_response,
          })
        end

        it "retries the transaction forcing the transaction_source and sequence" do
          expect(stellar_client).to receive(:send_payment).with(
            from: from,
            to: to,
            amount: amount,
            memo: nil,
            transaction_source: channel_account,
            sequence: 1,
          ).and_raise(timeout_error)

          expect(Retry).to receive(:execute).with(
            stellar_client: stellar_client,
            from: from,
            to: to,
            amount: amount,
            memo: nil,
            tries: 2,
            seeds: seeds,
            horizon_url: CONFIG[:horizon_url],
            redis_url: CONFIG[:redis_url],
            force_transaction_source: channel_account,
            force_sequence_number: 1,
            force_lock: true,
          ).and_return(retried_ctx)

          result = described_class.execute(
            stellar_client: stellar_client,
            from: from,
            to: to,
            amount: amount,
            memo: nil,
            tries: 2,
            seeds: seeds,
            horizon_url: CONFIG[:horizon_url],
            redis_url: CONFIG[:redis_url],
            channel_account: channel_account,
            next_sequence_number: 1,
          )

          expect(result.send_asset_response).to be retried_send_asset_response
        end
      end

      context "a non Faraday::ClientError" do
        let(:from) { Stellar::Account.from_seed(CONFIG[:sender_seed]) }
        let(:to) { Stellar::Account.from_address(CONFIG[:destination_address]) }
        let(:amount) { Stellar::Amount.new(1) }
        let(:channel_account) do
          Stellar::Account.from_seed(CONFIG[:payment_channel_seeds].sample)
        end
        let(:seeds) do
          CONFIG[:payment_channel_seeds].map do |seed|
            Stellar::Account.from_seed(seed)
          end
        end

        it "raises the error" do
          expect(stellar_client).to receive(:send_payment).with(
            from: from,
            to: to,
            amount: amount,
            memo: nil,
            transaction_source: channel_account,
            sequence: 1,
          ).and_raise(StandardError)

          expect do
            described_class.execute(
              stellar_client: stellar_client,
              from: from,
              to: to,
              amount: amount,
              memo: nil,
              channel_account: channel_account,
              next_sequence_number: 1,
              tries: 2,
              seeds: seeds,
              horizon_url: CONFIG[:horizon_url],
              redis_url: CONFIG[:redis_url],
            )
          end.to raise_error(StandardError)
        end
      end

      context "any Faraday::ClientError is raised" do
        let(:from) { Stellar::Account.random }
        let(:to) { Stellar::Account.random }
        let(:amount) { Stellar::Amount.new(1) }
        let(:channel_account) { Stellar::Account.random }
        let(:seeds) { CONFIG[:payment_channel_seeds] }
        let(:horizon_url) { CONFIG[:horizon_url] }
        let(:redis_url) { CONFIG[:redis_url] }
        let(:error) { Faraday::ClientError.new(nil, nil) }
        let(:retry_result) do
          LightService::Context.new(send_asset_response: double)
        end

        it "returns the unsuccessful response" do
          expect(stellar_client).to receive(:send_payment)
            .and_raise(error)

          expect(Retry).to receive(:execute).with(
            stellar_client: stellar_client,
            from: from,
            to: to,
            amount: amount,
            memo: nil,
            tries: 2,
            seeds: seeds,
            horizon_url: horizon_url,
            redis_url: redis_url,
            force_transaction_source: channel_account,
            force_sequence_number: 1,
            force_lock: true,
          ).and_return(retry_result)

          described_class.execute(
            stellar_client: stellar_client,
            from: from,
            to: to,
            amount: amount,
            memo: nil,
            channel_account: channel_account,
            next_sequence_number: 1,
            tries: 2,
            seeds: seeds,
            horizon_url: horizon_url,
            redis_url: redis_url,
          )
        end
      end

    end
  end
end
