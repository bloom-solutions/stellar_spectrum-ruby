require 'spec_helper'

module StellarSpectrum
  RSpec.describe Log do
    
    context "with a logger" do
      it "does not return nil" do
        StellarSpectrum.configure { |c| c.logger = Logger.new("tmp/test.log") }
        log_result = described_class.write("Hello")
        expect(log_result).not_to be_nil
      end
    end

    context "without a logger" do
      it "returns nil" do
        StellarSpectrum.configure {|c| c.logger = nil}
        log_result = described_class.write("Hello")
        expect(log_result).to be_nil
      end
    end

  end
end
