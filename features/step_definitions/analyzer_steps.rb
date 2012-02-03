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

Given /^two database csv files that are exactly the same$/ do
  @file1 = File.open('data/NSTD 30x Dyn 10.0.0.0 FX Pad6.csv', 'r')
  @file2 = File.open('data/NSTD 30x Dyn 10.0.0.0 FX Pad6 - Copy.csv', 'r')
end

When /^compared to each other$/ do
  @analyzer = QCRecipeSuite::Analyzer.new(output)
  @analyzer.compare(@file1, @file2)
end

Then /^the analyzer should print "([^"]*)"$/ do |message|
  output.messages.should include(message)
end

Given /^two database csv files that are from the same pad but very different$/ do
  @file1 = File.open('data/NSTD 30x Dyn 10.0.0.0 FX Pad6.csv', 'r')
  @file2 = File.open('data/NSTD 30x Dyn 10.0.0.0 FX Pad6 - Bad.csv', 'r')
end

After do
  @file1.close
  @file2.close
end
