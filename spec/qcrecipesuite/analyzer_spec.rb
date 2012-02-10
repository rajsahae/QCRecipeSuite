#!/usr/bin/env ruby
# encoding: UTF-8
require 'spec_helper'

module QCRecipeSuite
  describe Analyzer do
    describe "#compare" do

      let(:output) { double('output').as_null_object }
      let(:original) { File.new('data/spec/analyzer/original.csv', 'r') }
      let(:copy) { File.new('data/spec/analyzer/copy.csv', 'r') }
      let(:bad) { File.new('data/spec/analyzer/bad.csv', 'r') }
      let(:analyzer) { Analyzer.new(output) }

      it "prints PASSED for two files that are exactly the same" do
        output.should_receive(:puts).with('FULL SET PASSED').once
        analyzer.compare(original, copy)
      end

      it "prints FAILED for two files that are very different" do
        output.should_receive(:puts).with('FULL SET FAILED').once
        analyzer.compare(original, bad) 
      end

      it "should print group and comparison details for each group processed" do
        output.should_receive(:puts).with('PASSED - SQC Acq-SR OCD Short2 FX:4X Pad6 FX:SQC NSTD:# 24').once
        analyzer.compare(original, copy)
      end
    end
  end
end
