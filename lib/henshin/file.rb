module Henshin

  class File

    @types = {}

    # Registers a new file type which can then be used by .create.
    #
    # @param ext [String] Extension to associate file type with
    # @param type [File] Subclass of File
    def self.register(ext, type)
      @types[ext] = type
    end

    # Creates a new File, or if possible a subclass of File, depending on the
    # extension of the path given.
    #
    # @param site [Site]
    # @param path [Pathname]
    def self.create(site, path)
      klass = @types[::File.extname(path)] || self
      klass.new(site, path)
    end


    YAML_REGEX = /\A---\n^(.*?)\n^---\n?(.*)\z/m

    attr_reader :path

    # @param site [Site]
    # @param path [Pathname, String]
    def initialize(site, path)
      @site = site
      @path = Pathname.new(path)
    end

    # @return [Array<String>] An array of two parts. The first is the yaml part
    # of the file, the second is the text part.
    def read
      contents = @path.read || ""
      if match = contents.match(YAML_REGEX)
        match.to_a[1..2]
      else
        ['', contents]
      end
    end

    # return [Hash]
    def yaml
      (YAML.load(read[0]) || {}).symbolise
    end

    # @return [Hash]
    def data
      {
        mime:      mime,
        url:       url,
        permalink: permalink
      }.merge(yaml)
    end

    # @return [String] Extension for the file to be written.
    def extension
      @path.extname
    end

    # @return [String] The mime type for the file to be written.
    def mime
      Rack::Mime.mime_type extension
    end

    # @return [String] Text of the file.
    def text
      read[1]
    end

    # @retrun [String] Absolute url to the file, including 'index.html'.
    def permalink
      "/#{@path.relative_path_from(@site.root)}".sub(@path.extname, extension)
    end

    # @return [String] Pretty url to the file.
    def url
      permalink
    end

    # @param dir [String, Pathname] Directory the site is being built in.
    # @return [Pathname]
    def write_path(dir)
      @site.root + dir + permalink[1..-1]
    end

    def write(dir)
      Writer.write write_path(dir), text
      UI.wrote permalink[1..-1]
    end

  end

  class CoffeeScriptFile < File
    def text
      CoffeeScriptEngine.render super
    end

    def extension
      '.js'
    end
  end

  File.register '.coffee', CoffeeScriptFile

  class RedcarpetFile < File
    def text
      RedcarpetEngine.render super
    end

    def extension
      '.html'
    end
  end

  File.register '.md', RedcarpetFile

  class SassFile < File
    def text
      SassEngine.render super
    end

    def extension
      '.css'
    end
  end

  File.register '.sass', SassFile

  class SlimFile < File
    def text
      SlimEngine.render super, @site.data.merge(data)
    end

    def extension
      '.html'
    end
  end

  File.register '.slim', SlimFile

end
