#!/usr/bin/env ruby
# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'qcrecipesuite'

raise StandardError.new "You must specify two comparison files" if ARGV.empty?
file1, file2 = ARGV[0], ARGV[1]
[file1, file2].each do |file| 
  raise ArgumentError.new "File: #{file} doesn't exist" unless File.exists?(file)
end
analyzer = QCRecipeSuite::Analyzer.new(STDOUT)
File.open(file1, 'r:Windows-1252') do |first|
  File.open(file2, 'r:Windows-1252') do |second|
    analyzer.compare(first, second)
  end
end
