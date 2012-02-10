#!/usr/bin/env ruby
# encoding: UTF-8
require 'spec_helper'

module QCRecipeSuite
  describe Point do
    context "New Point" do
      let(:single_point) { File.open('data/spec/point/point.csv', 'r') }
      let(:datetime1) { DateTime.new(y=2011, m=8, d=27, h=0, min=24) }
      let(:parameters) do
        { :point => "1 (LAMPEXP)",
          :thick1 => "10189.16",
          :mse => "4.322",
          :gain_te => "1",
          :gain_tm => "1",
          :x => "44.985",
          :y => "-0.216" }
      end

      before(:each) do
        @point = Point.new(single_point.readlines)
      end

      it "should store the DateTime" do
        @point.datetime.should == datetime1
      end

      it "should store the Film Name" do
        @point.filmname.should == "SQC Acq-SR OCD Short2 FX"
      end

      it "should store the Stage Group" do
        @point.stagegroup.should == "4X Pad6 FX"
      end

      it "should store the Lot ID" do
        @point.lotid.should == "SQC NSTD"
      end

      it "should store the Wafer ID" do
        @point.waferid.should == "# 24"
      end

      it "should store the parameter headers and data" do
        @point.parameters.should == parameters
      end

      it "should provide it's group info" do
        hash = ["SQC Acq-SR OCD Short2 FX", "4X Pad6 FX", "SQC NSTD", "# 24"].join(':').hash
        @point.group_id.should == hash
      end

      context "groups" do
        before(:each) do
          single_point.rewind
        end

        it "should identify a point in it's own group" do
          point = Point.new(single_point.readlines)
          @point.in_same_group?(point).should be_true
        end

        it "should identify a point not in it's own group" do
          point = Point.new(single_point.readlines)
          point.lotid = "Fake ID"
          @point.in_same_group?(point).should be_false
        end
      end

      after(:each) do
        single_point.close
      end
    end

    context "Point bugs" do
      context "dealing with different data formats" do
        it "should handle formats after being saved in excel" do
          File.open("data/spec/point/date1.csv", 'r') do |date1|
            Point.new(date1.readlines).should_not raise_error(ArgumentError)
          end
        end

        it "should handle formats straight from N2000" do
          File.open("data/spec/point/date2.csv", 'r') do |date2|
            Point.new(date2.readlines).should_not raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
