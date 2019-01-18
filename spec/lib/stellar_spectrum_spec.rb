require "spec_helper"

RSpec.describe StellarSpectrum do
  describe ".configure" do
    it "allows setting of redis_url" do
      StellarSpectrum.configure {|c| c.redis_url = "redis://myredis"}
      expect(StellarSpectrum.configuration.redis_url).
        to eq "redis://myredis"
    end

    it "allows setting of the seeds" do
      StellarSpectrum.configure {|c| c.seeds = %w(S1 S2 S3)}
      expect(StellarSpectrum.configuration.seeds).
        to match_array(%w(S1 S2 S3))
    end

    it "allows setting of the horizon_url" do
      StellarSpectrum.configure {|c| c.horizon_url = "https://horizon.com"}
      expect(StellarSpectrum.configuration.horizon_url).
        to eq("https://horizon.com")
    end

    it "allows setting of logger" do
      logger = Logger.new("tmp/log.log")
      StellarSpectrum.configure {|c| c.logger = logger}
      expect(StellarSpectrum.configuration.logger).to eq(logger)
    end
  end

  describe ".new" do
    it "returns a StellarSpectrum::Client" do
      expect(described_class.new).to be_a StellarSpectrum::Client
    end

    context "config specified" do
      before do
        StellarSpectrum.configure do |c|
          c.redis_url = "readdes"
          c.seeds = %w(S1)
          c.horizon_url = "h.com"
        end
      end

      it "returns a StellarSpectrum::Client with specified config" do
        client = described_class.new({
          redis_url: "redis",
          seeds: %w(S2),
          horizon_url: "ho.com"
        })
        expect(client.redis_url).to eq "redis"
        expect(client.seeds).to match_array(%w(S2))
        expect(client.horizon_url).to eq "ho.com"
      end
    end

    context "no config specified" do
      let(:logger) { Logger.new("tmp/log.log") }
      before do
        StellarSpectrum.configure do |c|
          c.redis_url = "readdes"
          c.seeds = %w(S1)
          c.horizon_url = "h.com"
          c.logger = logger
        end
      end

      it "returns a StellarSpectrum::Client with default config" do
        client = described_class.new
        expect(client.redis_url).to eq "readdes"
        expect(client.seeds).to match_array(%w(S1))
        expect(client.horizon_url).to eq "h.com"
      end
    end
  end
end
