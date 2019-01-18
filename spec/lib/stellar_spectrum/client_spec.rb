require "spec_helper"

module StellarSpectrum
  RSpec.describe Client do

    let(:stellar_client) do
      InitStellarClient.execute(horizon_url: CONFIG[:horizon_url])
        .stellar_client
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
        horizon_url: CONFIG[:horizon_url]
      )

      tx = client.send_payment(
        from: from_account,
        to: destination_account,
        amount: Stellar::Amount.new(1),
        memo: "MOMO",
      )

      tx_hash = tx._attributes["hash"]

      tx = stellar_client.horizon.transaction(hash: tx_hash)
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
        horizon_url: CONFIG[:horizon_url]
      )

      tx = client.send_payment(
        from: from_account,
        to: destination_account,
        amount: Stellar::Amount.new(1),
        memo: "MOMO",
      )

      tx_hash = tx._attributes["hash"]

      tx = stellar_client.horizon.transaction(hash: tx_hash)
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
          horizon_url: CONFIG[:horizon_url]
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

    context "transaction_source and sequence are given" do
      let(:channel_account) do
        Stellar::Account.from_seed(seeds.first)
      end
      let(:seeds) do
        # Return one seed so we can be sure the first time around we send the tx
        # that we pick the only available seed
        [CONFIG[:payment_channel_seeds].last]
      end

      it "uses the given transaction_source and sequence", vcr: {record: :once} do
        client = described_class.new(
          redis_url: CONFIG[:redis_url],
          seeds: CONFIG[:payment_channel_seeds],
          horizon_url: CONFIG[:horizon_url],
          seeds: seeds,
        )

        next_sequence_number = GetSequenceNumber.execute(
          stellar_client: stellar_client,
          channel_account: channel_account,
        ).next_sequence_number

        tx_0 = client.send_payment(
          from: from_account,
          to: destination_account,
          amount: Stellar::Amount.new(1),
          memo: "MOMO",
        )

        expect(tx_0._response).to be_success
        tx_0_hash = tx_0._attributes["hash"]

        tx_1 = client.send_payment(
          from: from_account,
          to: destination_account,
          amount: Stellar::Amount.new(1),
          memo: "MOMO",
          transaction_source: channel_account,
          sequence: next_sequence_number,
        )

        expect(tx_1._response).to be_success
        tx_1_hash = tx_1._attributes["hash"]

        expect(tx_0_hash).to eq tx_1_hash
      end
    end

    context "sending payment times out" do
      let(:channel_account) do
        Stellar::Account.from_seed(seeds.first)
      end

      it "retries until it is able to send it" do
        VCR.use_cassette(
          "StellarSpectrum_Client/"\
          "sending_payment_times_out/"\
          "definition-account_info-post_tx_timeout_2x_then_success",
        ) do
          client = described_class.new(
            redis_url: CONFIG[:redis_url],
            seeds: CONFIG[:payment_channel_seeds],
            horizon_url: CONFIG[:horizon_url],
          )

          result = client.send_payment(
            from: from_account,
            to: destination_account,
            amount: Stellar::Amount.new(1),
          )

          expect(result._success?).to be true
        end
      end
    end

  end
end
