module Henshin

  # Uses {RedcarpetEngine} to render text.
  class RedcarpetFile < File

    # @return [String] Html rendered from the markdown source.
    def text
      RedcarpetEngine.render super
    end

    # @return [String] The pretty url without the 'index.html' part.
    def url
      super.sub /index\.html$/, ''
    end

    def extension
      '.html'
    end
  end

  File.register '.md', RedcarpetFile

end
