require 'spec_helper'

module StellarSpectrum
  RSpec.describe LockChannel do

    let(:redis) { InitRedis.execute(redis_url: CONFIG[:redis_url]).redis }
    let(:channel_account) { Stellar::Account.random }

    context "force_lock is false" do
      context "channel is not locked" do
        it "locks the channel" do
          result = described_class.execute(
            channel_account: channel_account,
            redis: redis,
            next_sequence_number: 2,
            force_lock: false,
          )

          expect(result.successfully_locked).to be true
        end
      end

      context "channel is already locked" do
        it "does not lock the channel" do
          described_class.execute(
            channel_account: channel_account,
            redis: redis,
            next_sequence_number: 2,
            force_lock: false,
          )

          result = described_class.execute(
            channel_account: channel_account,
            redis: redis,
            next_sequence_number: 2,
            force_lock: false,
          )

          expect(result.successfully_locked).to be false
        end
      end
    end

    context "force_lock is true" do
      it "locks successfully, refreshing the ttl" do
        described_class.execute(
          channel_account: channel_account,
          redis: redis,
          next_sequence_number: 2,
          force_lock: false,
        )

        result = described_class.execute(
          channel_account: channel_account,
          redis: redis,
          next_sequence_number: 2,
          force_lock: true,
        )

        expect(result.successfully_locked).to be true
      end
    end

  end
end
