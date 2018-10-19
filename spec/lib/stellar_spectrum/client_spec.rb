require "spec_helper"

module StellarSpectrum
  RSpec.describe Client do

    let(:stellar_client) do
      Stellar::Client.new(horizon: CONFIG[:horizon_url])
    end
    let(:from_account) { Stellar::Account.from_seed(CONFIG[:sender_seed]) }
    let(:destination_account) do
      Stellar::Account.from_address(CONFIG[:destination_address])
    end

    it("uses a payment channel", {
      vcr: {record: :once, match_requests_on: [:method]}
    }) do
      client = described_class.new(
        redis_url: CONFIG[:redis_url],
        seeds: CONFIG[:payment_channel_seeds],
        horizon_url: CONFIG[:horizon_url],
        logger: Logger.new("tmp/test.log"),
      )

      tx = client.send_payment(
        from: from_account,
        to: destination_account,
        amount: Stellar::Amount.new(1),
        memo: "MOMO",
      )

      tx_hash = tx._attributes["hash"]

      tx = client.stellar_client.horizon.transaction(hash: tx_hash)
      expect(tx.source_account).to_not eq from_account.address

      operation = tx.operations.records.first
      expect(operation.from).to eq from_account.address
    end

    it("passes on the memo", {
      vcr: {record: :once, match_requests_on: [:method]}
    }) do
      client = described_class.new(
        redis_url: CONFIG[:redis_url],
        seeds: CONFIG[:payment_channel_seeds],
        horizon_url: CONFIG[:horizon_url],
        logger: Logger.new("tmp/test.log"),
      )

      tx = client.send_payment(
        from: from_account,
        to: destination_account,
        amount: Stellar::Amount.new(1),
        memo: "MOMO",
      )

      tx_hash = tx._attributes["hash"]

      tx = client.stellar_client.horizon.transaction(hash: tx_hash)
      expect(tx.memo).to eq "MOMO"
    end

    it "sends payments through available channels" do
      # Allow external calls. Because of threads, it is impossible
      # to know the order in which the calls will be made. This is an expensive
      # spec to run, and requires that the CI has SENDER_SEED and
      # PAYMENT_CHANNEL_SEEDS set
      WebMock.allow_net_connect!
      VCR.turned_off do
        client = described_class.new(
          redis_url: CONFIG[:redis_url],
          seeds: CONFIG[:payment_channel_seeds],
          horizon_url: CONFIG[:horizon_url],
          logger: Logger.new("tmp/test.log"),
        )

        original_destination_balance = stellar_client.
          account_info(destination_account).
          balances.find { |b| b["asset_type"] == "native" }["balance"].to_f

        threads = 5.times.map do |n|
          Thread.new do
            client.send_payment(
              from: from_account,
              to: destination_account,
              amount: Stellar::Amount.new(1),
            )
          end
        end

        threads.map(&:join)

        new_destination_balance = stellar_client.
          account_info(destination_account).
          balances.find { |b| b["asset_type"] == "native" }["balance"].to_f

        expect(new_destination_balance - original_destination_balance).
          to eq(5 * 1)
      end
      WebMock.disable_net_connect!
    end

  end
end
