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
            if group.within_limits_of?(otherset[group.name]) && otherset[group.name].within_limits_of?(group)
              puts 'PASSED' + ' - ' + group.name 
              memo && true
            else
              puts 'FAILED' + ' - ' + group.name
              memo && false
            end
          else
            memo && true
          end
        end
      else
        if self.within_limits_of?(otherset) && otherset.within_limits_of?(self)
          puts 'PASSED' + ' - ' + otherset.name 
          true
        else
          puts 'FAILED' + ' - ' + otherset.name
          false
        end
      end
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
      if groups.size == 1
        groups.first.name
      else
        "Multi-Group name"
      end
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
