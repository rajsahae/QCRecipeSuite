require 'statsample'

module QCRecipeSuite
  class Dataset
    def initialize(file)
      temp = []
      file.each do |line|
        if line =~ /^[\s,]*$/
          points << Point.new(temp)
          temp.clear
        else
          temp << line
        end
      end
      points << Point.new(temp) unless temp.empty?
    end

    def points
      @points ||= []
    end

    def similar_to? otherset
      # Assuming the two sets have enough points to calculate Mean and Standard
      # Deviation we will define Set1.similar_to?(Set2) to be true as long as:
      # Set2.mean-3*Set2.stdev < Set1.mean < Set2.mean+3*Set2.stdev and vice
      # versa
      self.within_limits_of?(otherset) &&
        otherset.within_limits_of?(self)
    end

    def within_limits_of? otherset
      otherset.lowerlimit < self.mean && 
        self.mean < otherset.upperlimit
    end

    def mean
      @mean ||= points_as_float.to_scale.mean
    end

    def stdev
      @stdev ||= points_as_float.to_scale.standard_deviation_sample
    end

    def lowerlimit
      @lcl ||= mean - 3 * stdev
    end

    def upperlimit
      @ucl ||= mean + 3 * stdev
    end

    private

    def points_as_float
      @paf ||= points.map{|point| point.parameters[:thick1].to_f}
    end
  end
end
