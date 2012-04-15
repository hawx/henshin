module Henshin

  class RedcarpetFile < File
    def text
      RedcarpetEngine.render super
    end

    def url
      super.sub /index\.html$/, ''
    end

    def extension
      '.html'
    end
  end

  File.register '.md', RedcarpetFile

end
