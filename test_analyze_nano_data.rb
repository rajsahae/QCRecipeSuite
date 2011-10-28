# test_analyze_nano_data.rb
# By Raj Sahae
# 2011.10.18
#
# Unit Test Class for AnalyzeNanoData.rb

$:.push Dir.pwd

require 'test/unit'
require 'analyze_nano_data'

class Hash
  # Returns a hash that represents the difference between two hashes.
  #
  # Examples:
  #
  #   {1 => 2}.diff(1 => 2)         # => {}
  #   {1 => 2}.diff(1 => 3)         # => {1 => 2}
  #   {}.diff(1 => 2)               # => {1 => 2}
  #   {1 => 2, 3 => 4}.diff(1 => 2) # => {3 => 4}
  def diff(h2)
    dup.delete_if { |k, v| h2[k] == v }.merge!(h2.dup.delete_if { |k, v| has_key?(k) })
  end
end

class TestAnalyzeNanoData < Test::Unit::TestCase
  def setup
    @files = Array.new.push "Pad 9 - Slot 12 (af8f64).csv"
    @nd = NanoData.new.process(@files)
    @bf = BatchFile.new(@files[0])
    @test_hash = Hash["Version","2.7.0.148","Strategy Name","GF STI W60P600 slot 12","Date","09/26/2011 11:55:41 AM","Duration","4 mins:26 secs","Used Cluster","True","# of Nodes","8","Wvls splitting","False","Used Precis","False","Used Sliver Engine","True","Data Header Begin Column","19"]
    #@parameter_check = clean_str 'Filename,Si Rnd Ht (nm),Si Rnd BCD (nm),Si Rnd TCD (nm),Si Ht (nm),Si SWA (°),Si TCD (nm),SiO2 Ht (nm),Si MCD (nm),Nitride Ht (nm),Nitride BCD (nm),Nitride SWA (°),Nitride TCD (nm),Oxide Res (nm),gain_rcw,pitch (nm),Iterations,FitDataTime (s),MSE,MEASURE_X,MEASURE_Y,REAL_COORDINATES,SYSTEM_NAME,SYSTEM_MODEL,N2000_VERSION,LOT_ID,WAFER_ID,PROCESS_ID,MATERIAL_ID,CARRIER_ID,STAGE_GROUP_ID,WAFER_NAME,STAGE_NAME,CASSETTE_NAME,FILM_NAME,TIME_ACQUISITION,WAFER_SIZE,SLOT,GROUP_POINTS,SCAN_NUMBER,END_OF_WAFER,END_OF_LOT,USE_DIE_MAP,REF_DIE_X,REF_DIE_Y,DIE_PITCH_X,DIE_PITCH_Y,MEASURE_DIE_X,MEASURE_DIE_Y,DIE_ROW,DIE_COLOUMN,IN_DIE_POINT_TAG,DIE_SEQUENCE'
    #@result_check = clean_str 'Y:\Project\GF CMP Demo 8-2011\Collected Data\Impulse2\Raw spectra\Spectrum Impulse2\STI-Metro-Pad9-flipped\Slot 12\test1.dat,50.000000,175.385750,128.754984,204.138115,80.000000,56.764869,2.000000,110.198281,30.944924,56.059561,80.000000,45.146711,0.000000,0.988409,600.000000,2.000000,8.034000,0.011951,-16.203000,26.962000,1,Beta 2,IMPULSE,10.0.0.0,,lp1_12,,lp1_12,,Metro pad#9,GF STI final cycle,GF STI Final,GF STI final cycle,STI Metro Pad#09,2011/09/15 08:43:04 AM,300,1,6,1,0,0,1,-22.455400,3.352310,25.914200,32.913500,6.252100,23.609800,0.000000,0.000000,,1'
  end

  def teardown
    # Nothing
  end

  def test_nanodata
    #puts @nd.batch_files[0].headers.class
    #puts @test_hash.diff(@nd.batch_files[0].headers)
    assert_equal(@test_hash, @nd.batch_files[0].headers)
    assert_equal(@files, @nd.filenames)
    assert_equal(true, @nd.analyze)
  end

  def test_batchfile
    assert_equal(@files[0], @bf.name)
    assert_equal(10, @bf.headers.length)
    assert_equal(@test_hash, @bf.headers)
    assert_equal(53, @bf.parameters.length)
    #assert_equal(@parameter_check, @bf.parameters)
    assert_equal(150, @bf.results.length)
    #assert_equal(@result_check, @bf.results[0])
    #puts @bf.results[0]
    File.open("table.csv", 'w'){|file| file.puts @bf.to_table}
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
