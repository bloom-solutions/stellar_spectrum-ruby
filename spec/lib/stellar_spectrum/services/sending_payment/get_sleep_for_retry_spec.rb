require 'spec_helper'

module StellarSpectrum
  module SendingPayment
    RSpec.describe GetSleepForRetry do

      context(
        "output of Fibo is less than " \
        "#{Client::MAX_LOCK_TIME_IN_SECONDS}"
      ) do
        it "is the output of Fibo" do
          fibo = Client::MAX_LOCK_TIME_IN_SECONDS - 5
          expect(Fibo).to receive(:call).with(20).and_return(fibo)
          expect(described_class.(20)).to eq fibo
        end
      end

      context(
        "output of Fibo greater than or equal to " \
        "#{Client::MAX_LOCK_TIME_IN_SECONDS}"
      ) do
        it "is #{Client::MAX_LOCK_TIME_IN_SECONDS - 5}" do
          fibo = Client::MAX_LOCK_TIME_IN_SECONDS
          expect(Fibo).to receive(:call).with(20).and_return(fibo)
          expect(described_class.(20)).
            to eq Client::MAX_LOCK_TIME_IN_SECONDS - 5

          fibo = Client::MAX_LOCK_TIME_IN_SECONDS + 10
          expect(Fibo).to receive(:call).with(20).and_return(fibo)
          expect(described_class.(20)).
            to eq Client::MAX_LOCK_TIME_IN_SECONDS - 5
        end
      end

    end
  end
end
