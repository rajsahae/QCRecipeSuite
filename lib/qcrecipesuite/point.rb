module QCRecipeSuite
  class Point
    def [](key)
      properties[key]
    end

    def []=(key, value)
      properties[key] = value
    end

    def properties
      @properties ||= Hash.new
    end
  end
end
