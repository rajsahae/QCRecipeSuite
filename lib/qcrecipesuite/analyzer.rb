module QCRecipeSuite
  class Analyzer
    def initialize(output)
      @output = output
    end

    def compare(oldfile, newfile)
      oldset = Dataset.new(oldfile)
      newset = Dataset.new(newfile)

      puts oldset.similar_to?(newset) ? "PASSED" : "FAILED"
    end

    def puts string
      @output.puts string
    end
  end
end
