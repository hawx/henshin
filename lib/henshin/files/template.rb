module Henshin

  # A template file.
  class Template < SlimFile

    def text
      @path.read
    end

    def name
      @path.basename.to_s.split('.').first
    end

    # @param other [#text, #data] File to run through template
    # @param data [Hash] Extra data to merge before rendering
    def template(other, data={})
      data = @site.data.merge(other.data.merge(data))
      SlimEngine.render text, data
    end
  end

  class EmptyTemplate < Template

    def initialize
      # ...
    end

    def text
      ""
    end

    def name
      "none"
    end

    def template(*args)
      ""
    end
  end

end
