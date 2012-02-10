#!/usr/bin/env ruby
# encoding: UTF-8
require 'csv'

module QCRecipeSuite
  class Point
    attr_accessor :datetime, :filmname, :stagegroup, :lotid, :waferid, :parameters

    def initialize(lines)
      keys, values = []
      lines.each do |line|
        CSV.parse(line.force_encoding('Windows-1252')) do |row|
          case row.compact[0]
          when /^Date/
            if row[1].match(/\d$/)
              @datetime = DateTime.strptime(row[1], '%m/%d/%Y %H:%M')
            else
              @datetime = DateTime.parse(row[1])
            end
          when /^(Film)|(Stage)|(Lot)|(Wafer)/
            send(attrib_clean(row[0]), row[1])
          when /^Title/
            keys = row[1..-1].compact.map{|e| key_clean e}
          when /^\d/
            values = row[0..-1].compact
          end
        end
      end
      @parameters = Hash[keys.zip values]
    end

    def group_id
      @group_id ||= generate_group_id
    end

    def in_same_group? otherpoint
      group_id.eql? otherpoint.group_id
    end

    def groupname
      [@filmname, @stagegroup, @lotid, @waferid].join(':')
    end

    private

    def attrib_clean string
      string[/^([\w\s]*):$/, 1].strip.downcase.gsub(/\s/, '').concat('=').to_sym
    end

    def key_clean string
      string[/^([\w\d]*)/, 1].downcase.to_sym
    end

    def generate_group_id
      [filmname, stagegroup, lotid, waferid].join(':').hash
    end
  end
end
