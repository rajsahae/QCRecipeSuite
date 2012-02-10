#!/usr/bin/env ruby
# encoding: UTF-8
require 'spec_helper'

module QCRecipeSuite
  describe Dataset do
    let(:output) { double('output') }
    context "With one stage group per file" do
      let(:file1) { File.open('data/spec/dataset/points1.csv', 'r') }
      let(:file2) { File.open('data/spec/dataset/points2.csv', 'r') }
      let(:file3) { File.open('data/spec/dataset/points3.csv', 'r') }
      let(:set1) { Dataset.new(file1, output) }
      let(:set2) { Dataset.new(file2, output) }
      let(:set3) { Dataset.new(file3, output) }
      let(:mean_delta) { 0.01 }
      let(:stdev_delta) { 0.000001 }

      describe "new dataset" do
        it "should have the correct number of points" do
          set1.should have(2).points
        end
      end

      describe "#similar_to?" do
        it "should return true for a similar set" do
          output.should_receive(:puts).once
          set1.should be_similar_to(set2)
        end

        it "should return false for a dissimilar set" do
          output.should_receive(:puts).twice
          set1.should_not be_similar_to(set3)
          set2.should_not be_similar_to(set3)
        end
      end

      describe "#within_limits_of?" do
        it "should return true for a set within limits of another set" do
          set1.should be_within_limits_of(set2)
        end

        it "should return false for a set not within limits of another set" do
          set3.should_not be_within_limits_of(set1)
        end
      end

      describe "statistical methods" do
        it "should calculate the mean of the points" do
          set1.mean.should be_within(mean_delta).of(10189.24)
          set2.mean.should be_within(mean_delta).of(10189.51)
          set3.mean.should be_within(mean_delta).of(10187.74)
        end

        it "should calculate the stdev of the points" do
          set1.stdev.should be_within(stdev_delta).of(0.113137)
          set2.stdev.should be_within(stdev_delta).of(0.205061)
          set3.stdev.should be_within(stdev_delta).of(0.59397)
        end

        it "should calculate the lower limit of the points" do
          set1.lowerlimit.should be_within(mean_delta).of(10188.9)
          set2.lowerlimit.should be_within(mean_delta).of(10188.89)
          set3.lowerlimit.should be_within(mean_delta).of(10185.96)
        end

        it "should calculate the upper limit of the points" do
          set1.upperlimit.should be_within(mean_delta).of(10189.58)
          set2.upperlimit.should be_within(mean_delta).of(10190.12)
          set3.upperlimit.should be_within(mean_delta).of(10189.52)
        end
      end

      after(:each) do
        file1.close
        file2.close
        file3.close
      end
    end

    context "With 2 stage groups per file" do
      context "With 30 points per stage group" do
        let(:file1) { File.open('data/spec/dataset/2groups-original.csv', 'r') }
        let(:file2) { File.open('data/spec/dataset/2groups-good.csv', 'r') }
        let(:file3) { File.open('data/spec/dataset/2groups-bad.csv', 'r') }
        let(:set1) { Dataset.new(file1, output) }
        let(:set2) { Dataset.new(file2, output) }
        let(:set3) { Dataset.new(file3, output) }
        let(:mean_delta) { 0.01 }
        let(:stdev_delta) { 0.000001 }

        describe "new dataset" do
          it "should have the correct number of points" do
            set1.should have(60).points
            set2.should have(60).points
            set3.should have(60).points
          end

          it "should have the correct number of groups" do
            set1.should have(2).groups
            set2.should have(2).groups
            set3.should have(2).groups
          end
          it "should have the correct number of points in each subgroup" do
            set1.groups[0].should have(30).points
            set1.groups[1].should have(30).points
            set2.groups[0].should have(30).points
            set2.groups[1].should have(30).points
            set3.groups[0].should have(30).points
            set3.groups[1].should have(30).points
          end
        end

        describe "#similar_to?" do
          it "should return true for a similar set" do
            output.should_receive(:puts).twice
            set1.should be_similar_to(set2)
          end

          it "should return false for a dissimilar set" do
            output.should_receive(:puts).twice
            set1.should_not be_similar_to(set3)
          end

          it "should return false for another dissimilar set" do
            output.should_receive(:puts).twice
            set2.should_not be_similar_to(set3)
          end
        end

        describe "statistical methods" do
          it "should calculate the mean of the points" do
            set1.groups[0].mean.should be_within(mean_delta).of(4308.02)
            set1.groups[1].mean.should be_within(mean_delta).of(10189.44)
            set2.groups[0].mean.should be_within(mean_delta).of(4307.99)
            set2.groups[1].mean.should be_within(mean_delta).of(10189.42)
            set3.groups[0].mean.should be_within(mean_delta).of(4305.36)
            set3.groups[1].mean.should be_within(mean_delta).of(10187.42)
          end

          it "should calculate the stdev of the points" do
            set1.groups[0].stdev.should be_within(stdev_delta).of(0.155379)
            set1.groups[1].stdev.should be_within(stdev_delta).of(0.158678)
            set2.groups[0].stdev.should be_within(stdev_delta).of(0.158441)
            set2.groups[1].stdev.should be_within(stdev_delta).of(0.168870)
            set3.groups[0].stdev.should be_within(stdev_delta).of(0.377591)
            set3.groups[1].stdev.should be_within(stdev_delta).of(0.168871)
          end

          it "should calculate the lower limit of the points" do
            set1.groups[0].lowerlimit.should be_within(mean_delta).of(4307.56)
            set1.groups[1].lowerlimit.should be_within(mean_delta).of(10188.97)
            set2.groups[0].lowerlimit.should be_within(mean_delta).of(4307.51)
            set2.groups[1].lowerlimit.should be_within(mean_delta).of(10188.91)
            set3.groups[0].lowerlimit.should be_within(mean_delta).of(4304.22)
            set3.groups[1].lowerlimit.should be_within(mean_delta).of(10186.91)
          end

          it "should calculate the upper limit of the points" do
            set1.groups[0].upperlimit.should be_within(mean_delta).of(4308.49)
            set1.groups[1].upperlimit.should be_within(mean_delta).of(10189.92)
            set2.groups[0].upperlimit.should be_within(mean_delta).of(4308.47)
            set2.groups[1].upperlimit.should be_within(mean_delta).of(10189.93)
            set3.groups[0].upperlimit.should be_within(mean_delta).of(4306.49)
            set3.groups[1].upperlimit.should be_within(mean_delta).of(10187.93)
          end
        end
      end

      context "With 2 points per stage group" do
        let(:file1) { File.open('data/spec/dataset/2groups-4pts-original.csv', 'r') }
        let(:file2) { File.open('data/spec/dataset/2groups-4pts-good.csv', 'r') }
        let(:file3) { File.open('data/spec/dataset/2groups-4pts-bad.csv', 'r') }
        let(:set1) { Dataset.new(file1, output) }
        let(:set2) { Dataset.new(file2, output) }
        let(:set3) { Dataset.new(file3, output) }
        let(:mean_delta) { 0.01 }
        let(:stdev_delta) { 0.000001 }

        describe "new dataset" do
          it "should have the correct number of points" do
            set1.should have(4).points
          end

          it "should have the correct number of groups" do
            set1.should have(2).groups
          end
          it "should have the correct number of points in each subgroup" do
            set1.groups[0].should have(2).points
            set1.groups[1].should have(2).points
          end
        end

        describe "#similar_to?" do
          it "should return true for a similar set" do
            output.should_receive(:puts).twice
            set1.should be_similar_to(set2)
          end

          it "should return false for a dissimilar set" do
            output.should_receive(:puts).twice
            set1.should_not be_similar_to(set3)
          end

          it "should return false for another dissimilar set" do
            output.should_receive(:puts).twice
            set2.should_not be_similar_to(set3)
          end
        end

        describe "statistical methods" do
          it "should calculate the mean of the points" do
            set1.groups[0].mean.should be_within(mean_delta).of(4307.99)
            set1.groups[1].mean.should be_within(mean_delta).of(10189.43)
            set2.groups[0].mean.should be_within(mean_delta).of(4307.96)
            set2.groups[1].mean.should be_within(mean_delta).of(10189.41)
            set3.groups[0].mean.should be_within(mean_delta).of(4305.46)
            set3.groups[1].mean.should be_within(mean_delta).of(10187.41)
          end

          it "should calculate the stdev of the points" do
            set1.groups[0].stdev.should be_within(stdev_delta).of(0.021213)
            set1.groups[1].stdev.should be_within(stdev_delta).of(0.381838)
            set2.groups[0].stdev.should be_within(stdev_delta).of(0.070711)
            set2.groups[1].stdev.should be_within(stdev_delta).of(0.424264)
            set3.groups[0].stdev.should be_within(stdev_delta).of(0.636396)
            set3.groups[1].stdev.should be_within(stdev_delta).of(0.424264)
          end

          it "should calculate the lower limit of the points" do
            set1.groups[0].lowerlimit.should be_within(mean_delta).of(4307.92)
            set1.groups[1].lowerlimit.should be_within(mean_delta).of(10188.28)
            set2.groups[0].lowerlimit.should be_within(mean_delta).of(4307.75)
            set2.groups[1].lowerlimit.should be_within(mean_delta).of(10188.14)
            set3.groups[0].lowerlimit.should be_within(mean_delta).of(4303.55)
            set3.groups[1].lowerlimit.should be_within(mean_delta).of(10186.14)
          end

          it "should calculate the upper limit of the points" do
            set1.groups[0].upperlimit.should be_within(mean_delta).of(4308.05)
            set1.groups[1].upperlimit.should be_within(mean_delta).of(10190.58)
            set2.groups[0].upperlimit.should be_within(mean_delta).of(4308.17)
            set2.groups[1].upperlimit.should be_within(mean_delta).of(10190.68)
            set3.groups[0].upperlimit.should be_within(mean_delta).of(4307.37)
            set3.groups[1].upperlimit.should be_within(mean_delta).of(10188.68)
          end
        end

        context "#groups" do
          let(:group1) {"SQC Acq-SR OCD VIS:4X Pad5 Vis:SQC NSTD:# 24"}
          let(:group2) {"SQC Acq-SR OCD Short2 FX:4X Pad6 FX:SQC NSTD:# 24"}

          it "should track it's group size with #groups.size" do
            set1.groups.size.should == 2
          end

          it "should indicate whether it contains a group with #have_group?" do
            set1.should have_group(group1)
            set1.should have_group(group2)
          end

          it "should retrieve a group name with #[name]" do
            set1[group1].name.should == group1
          end
        end
      end

      after(:each) do
        file1.close
        file2.close
        file3.close
      end
    end
  end
end

