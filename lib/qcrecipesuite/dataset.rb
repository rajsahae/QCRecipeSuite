require 'statsample'

module QCRecipeSuite
  class Dataset
    def initialize(file)
      temp = []
      file.each do |line|
        if line.force_encoding('Windows-1252') =~ /^[\s,]*$/
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
      if groups.size > 1
        groups.reject do |group|
          if otherset.has_group? group.name
            group.similar_to? otherset.groups[group.name]
          else
            true
          end
        end
      else
        self.within_limits_of?(otherset) &&
          otherset.within_limits_of?(self)
      end
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

    def groups
      @groups ||= generate_groups
    end

    def has_group? groupname
    end

    private

    def points_as_float
      @paf ||= points.map{|point| point.parameters[:thick1].to_f}
    end

    def generate_groups
      points.inject([]) do |memo, item|
        if subset = memo.find{|sub| sub.first.in_same_group? item}
          subset.push item
        else
          memo.push [item]
        end
        memo
      end.inject([]) do |grps, sub|
        grps.push Datagroup.new(sub)
      end
    end
  end

  class Datagroup < Dataset
    def initialize(point_array)
      @points = point_array
    end

    def name
    end
  end
end
