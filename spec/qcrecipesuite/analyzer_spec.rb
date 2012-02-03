require 'spec_helper'

module QCRecipeSuite
  describe Analyzer do
    describe "#compare" do

      let(:output) { double('output') }
      let(:original) { File.new('data/NSTD 30x Dyn 10.0.0.0 FX Pad6.csv', 'r') }
      let(:copy) { File.new('data/NSTD 30x Dyn 10.0.0.0 FX Pad6 - Copy.csv', 'r') }
      let(:bad) { File.new('data/NSTD 30x Dyn 10.0.0.0 FX Pad6 - Bad.csv', 'r') }
      let(:analyzer) { Analyzer.new(output) }

      it "prints PASSED for two files that are exactly the same" do
        output.should_receive(:puts).with('PASSED')
        analyzer.compare(original, copy)
      end

      it "prints FAILED for two files that are very different" do
        output.should_receive(:puts).with('FAILED')
        analyzer.compare(original, bad) 
      end
    end
  end
end
