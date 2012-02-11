#!/usr/bin/env ruby
# encoding: UTF-8

class Output
  def messages
    @messages ||= []
  end

  def puts(message)
    messages << message
  end
end

def output
  @output ||= Output.new
end

Given /^two database csv files "([^"]*)" and "([^"]*)"$/ do |file1, file2|
  @file1 = File.open(file1, 'r:Windows-1252')
  @file2 = File.open(file2, 'r:Windows-1252')
end

When /^compared to each other$/ do
  @analyzer = QCRecipeSuite::Analyzer.new(output)
  @analyzer.compare(@file1, @file2)
end

Then /^the analyzer should print "([^"]*)"$/ do |message|
  output.messages.should include(message)
end

After do
  @file1.close
  @file2.close
end
