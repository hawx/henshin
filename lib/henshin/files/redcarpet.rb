module Henshin

  # Uses {RedcarpetEngine} to render text.
  class RedcarpetFile < File

    # @return [String] Html rendered from the markdown source.
    def text
      puts Tilt::RedcarpetTemplate.new(:fenced_code_blocks => true) { super }.render

      Tilt::RedcarpetTemplate.new(nil, nil, @site.config[:redcarpet]) { super }.render
    end

    def extension
      '.html'
    end
  end

  File.register /\.md/, RedcarpetFile

end
