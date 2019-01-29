require 'spec_helper'

module StellarSpectrum
  RSpec.describe Fibo do

    it "returns the fibonacci sequence for the given integer" do
      expect(described_class.(0)).to eq 0
      expect(described_class.(1)).to eq 1
      expect(described_class.(2)).to eq 1
      expect(described_class.(3)).to eq 2
      expect(described_class.(4)).to eq 3
      expect(described_class.(5)).to eq 5
      expect(described_class.(20)).to eq 6765
    end

    it "caches the queries" do
      described_class.(40)

      start_time = Time.now
      time = 100.times.map { described_class.(40) }.sum
      end_time = Time.now

      expect(end_time - start_time).to be <= 1
    end

  end
end
