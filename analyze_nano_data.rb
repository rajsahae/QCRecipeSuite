# analyze_nano_data.rb
# By Raj Sahae
# 2011.10.18
#
# Class to replace VBA data analysis utility for processing nano data
# Should be able to do the following:
#   Must accept command line arguments
#   Use a user defined count or parse from headers
#   Mean, Range, 3Sigma of multiple data sets
#   Matching between tools using TMU or some other function

require 'optparse'

class NanoData
  attr_reader :filenames, :batch_files
  USAGE_STRING = "Usage: ruby analyze_nano_data.rb [OPTIONS] file1 file2 ...

  EXAMPLE: ruby analyze_nano_date.rb -vt -d source_dir -s results_dir batch_file1 batch_file2

  This will analyze all the files in 'source_dir' and files 'batch_file1' and 'batch_file2',
  create tables, and place all tables for those files in 'source_dir'.  The -d option does
  not currently work.\n\n"
  

  def initialize
    @optparser = OptionParser.new
    @options = {}
    @filenames = []
    @batch_files = []
  end
  
  def parse!
    optparse = OptionParser.new do |opts|
      opts.banner = USAGE_STRING 
      
      @options[:verbose]=false
      opts.on('-v', '--verbose', "Display verbose information.") do 
        @options[:verbose]=true
      end
      
      @options[:table]=false
      opts.on('-t', '--table', "Create a table structured for a pivot table") do |file|
        @options[:table]=true
      end

      @options[:combined_table]=false
      opts.on('-T', '--combined-table', "Create a table as with '-t', but combine all files into one table.") do
        @options[:combined_table]=true
      end

=begin
      opts.on('-d', '--directory DIR', "Process all CSV files in directory DIR.") do |dir|
        if Dir.exists?(dir)
          @filenames += Dir.entries(dir).select{|e| e =~ /\.csv$/}.collect{|e| dir + File::Separator + e}
          puts @filenames
        else
          puts "Directory '#{dir}' does not exist."
        end
      end
=end
      @options[:savepath] = Dir.pwd
      opts.on('-s', '--save-directory DIR', "Save all files to directory DIR.") do |dir|
        Dir.mkdir(dir) unless Dir.exists?(dir)
        @options[:savepath] = dir
      end
    end

    optparse.parse!
  end

  def process(filenames)
    @filenames += filenames
    filenames.each do |name|
      puts "Processing #{name}" if @options[:verbose]
      @batch_files.push(BatchFile.new(name))
    end
    self
  end

  def analyze
    @batch_files.each do |bf|
      file_prefix = @options[:savepath] + File::SEPARATOR + bf.name.match(/^(.*)\..*$/)[1]
      if @options[:table]
        puts "Creating table for #{bf.name}" if @options[:verbose]
        File.open("#{file_prefix}_table.csv", 'w') do |f| 
          f.puts bf.to_table.join("\n")
        end
      end
    end
    true
  end
end

class BatchFile
  attr_reader :name, :headers, :results, :parameters

  HEADER_LINE = /^([\w\d\s#]*),([\w\d\s\.\/:]*)$/
  PARAMETER_LINE = /^,(.*)$/
  DATA_LINE = /^([\w\d\.#\/:-\\-]*,?)*$/
  DIFFRACT_ENCODING = "Windows-1252"
  STAT_LINE_START = /(Max)|(Min)|(Range)|(Mean)|(Standard Deviation)/

  def initialize filename
    @name = filename  # String with batch filename
    @headers = {}     # Hash with batch file headers
    @results = []     # Multi-Dimensional array with regression results
    @parameters = []  # Array of labels for the batch parameters (ie Height, SWA, etc.)
    process @name 
  end
    
  def to_s
    @headers.to_s
  end
  
  # returns an array of strings
  def to_table
    begin_col = @headers["Data Header Begin Column"].to_i
    parameters = @parameters.slice(0,begin_col)
    headers = "Parameter,Value," + @parameters.slice(begin_col, @parameters.length).join(',')
    table = [headers]
    @results.each_with_index do |result, i1|
      parameters.each_with_index do |p, i2|
        table[i1*parameters.length + i2.next] = "#{p},#{result[i2]},#{result.slice(begin_col, result.length).join(',')}"
      end
    end
    return table
  end
  
  private

  def process filename
    File.open(filename, 'r') do |file|
      file.readlines.each do |line|
        line = clean_string line
        next unless line.split(',')[0].scan(STAT_LINE_START).empty?
        if not line[HEADER_LINE].nil?
          @headers[$1.strip] = $2.strip
        elsif not line[PARAMETER_LINE].nil?
          @parameters = $&.strip.split(',').drop(1).unshift("Filename")
        else
          @results.push line.strip.split(',')
        end
      end
    end
  end
  
  def clean_string str
    # Converting ASCII-8BIT to UTF-8 based domain-specific guesses
    if str.is_a? String
      begin
        # Try it as UTF-8 directly
        cleaned = str.dup.force_encoding('UTF-8')
        unless cleaned.valid_encoding?
          # Some of it might be old Windows code page
          cleaned = str.encode( 'UTF-8', 'Windows-1252' )
        end
        str = cleaned
      rescue EncodingError
        # Force it to UTF-8, throwing out invalid bits
        str.encode!( 'UTF-8', invalid: :replace, undef: :replace, :replace=>"?" )
      end
    end
  end

end

if __FILE__  == $0
  nd = NanoData.new
  nd.parse!
  nd.process(ARGV)
  nd.analyze
end

