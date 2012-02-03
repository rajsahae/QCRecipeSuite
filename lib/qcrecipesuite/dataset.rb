require 'csv'

module QCRecipeSuite
  class Dataset
    def initialize(file)
      file.each do |line|
        CSV.parse(line) do |row|
          case row[0]
          when /^Date/
            points << Point.new
            points.last[:datetime] = DateTime.strptime(row[1], '%m/%d/%Y %H:%M')
          when [/^Film/, /^Stage/, /^Lot/, /^Wafer/]
            points.last[row[0][/^([\w\s]*):$/, 1].strip.downcase.gsub(/\s/, '').to_sym] = row[1]
          end
        end
      end
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
    end

    def stdev
    end

    def lowerlimit
      mean - 3 * stdev
    end

    def upperlimit
      mean + 3 * stdev
    end
  end
end
