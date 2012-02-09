require 'statsample'

module QCRecipeSuite
  class Dataset
    def initialize(file, output=STDOUT)
      @output = output
      leftovers = file.inject([]) do |temp, line|
        if line.force_encoding('Windows-1252') =~ /^[\s,]*$/
          points << Point.new(temp)
          temp.clear
        else
          temp << line
        end
      end
      points << Point.new(leftovers) unless leftovers.empty?
    end
    
    def points
      @points ||= []
    end

    def puts string
      @output.puts string
    end

    def similar_to? otherset
      # Assuming the two sets have enough points to calculate Mean and Standard
      # Deviation we will define Set1.similar_to?(Set2) to be true as long as:
      # Set2.mean-3*Set2.stdev < Set1.mean < Set2.mean+3*Set2.stdev and vice
      # versa
      if groups.size > 1
        groups.inject(true) do |memo, group|
          if otherset.has_group? group.name
            if Dataset.within_each_others_limits?(group, otherset[group.name])
              Dataset.pass(group) && memo
            else
              Dataset.fail(group) && memo
            end
          else
            Dataset.skip(group) && memo
          end
        end
      else
        if Dataset.within_each_others_limits?(self, otherset)
          Dataset.pass self
        else
          Dataset.fail self
        end
      end
    end

    def Dataset.pass group
      group.puts 'PASSED' + ' - ' + group.name
      return true
    end

    def Dataset.fail group
      group.puts 'FAILED' + ' - ' + group.name
      return false
    end

    def Dataset.skip group
      group.puts 'SKIPPED' + ' - ' + group.name
      return true
    end

    def Dataset.within_each_others_limits?(set1, set2)
      set1.within_limits_of?(set2) && set2.within_limits_of?(set1)
    end

    def within_limits_of? otherset
      otherset.lowerlimit < self.mean && self.mean < otherset.upperlimit
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

    def [] groupname
      groups.find{|datagroup| datagroup.name.eql? groupname}
    end

    def has_group? groupname
      groups.any?{|datagroup| datagroup.name.eql? groupname}
    end

    def name
      groups.inject([]) do |memo, group|
        memo.push group.name 
      end.join(" - ")
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
        grps.push Datagroup.new(sub, @output)
      end
    end
  end

  class Datagroup < Dataset
    def initialize(point_array, output=STDOUT)
      @points = point_array
      @output = output
    end

    def name
      @points.first.groupname
    end
  end
end
