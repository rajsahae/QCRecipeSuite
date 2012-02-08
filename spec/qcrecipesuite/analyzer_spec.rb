require 'spec_helper'

module QCRecipeSuite
  describe Analyzer do
    describe "#compare" do

      let(:output) { double('output') }
      let(:original) { File.new('data/spec/analyzer/original.csv', 'r') }
      let(:copy) { File.new('data/spec/analyzer/copy.csv', 'r') }
      let(:bad) { File.new('data/spec/analyzer/bad.csv', 'r') }
      let(:analyzer) { Analyzer.new(output) }

      it "prints PASSED for two files that are exactly the same" do
        output.should_receive(:puts).with('FULL SET PASSED')
        analyzer.compare(original, copy)
      end

      it "prints FAILED for two files that are very different" do
        output.should_receive(:puts).with('FULL SET FAILED')
        analyzer.compare(original, bad) 
      end
    end
  end
end
