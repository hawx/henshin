module Henshin

  # A template file.
  module Template
    def text
      ::File.read(@path.to_s)
    end

    def name
      @path.basename.to_s.split('.').first
    end

    # @param other [#text, #data] File to run through template
    # @param data [Hash] Extra data to merge before rendering
    def template(other, data={})
      data = @site.data.merge(other.data.merge(data))
      Engines.render :slim, text, data
    end
  end

  File.apply %r{/templates/}, Template

  class EmptyTemplate
    include FileInterface

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
