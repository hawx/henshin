module Henshin

  # @abstract You will want to implement {#data}, {#text} and {#permalink}.
  module FileInterface

    # @return [Hash] Data for the file.
    def data
      {}
    end

    # @return [String] Text to write to the file.
    def text
      ""
    end

    # @return [String] The absolute url to the file.
    def permalink
      ""
    end

    # @return [String] A pretty url to the file, by default {#permalink}.
    def url
      permalink
    end

    # @param dir [Pathname] Path the site is being built to.
    # @return [Pathname] Path to write the file to.
    def write_path(dir)
      dir + permalink[1..-1]
    end

    # Writes the file.
    #
    # @param dir [Pathname] Path the site is built to.
    def write(dir)
      Writer.write write_path(dir), text
      UI.wrote permalink[1..-1]
    rescue => e
      puts "\nError writing #{inspect}".red.bold
      puts "  #{e.backtrace.shift}"
      puts e.backtrace.take(3).map {|l| "    #{l}" }.join("\n")
      exit 1
    end

    # Compares the files based on their permalinks.
    #
    # @param other [File]
    def <=>(other)
      permalink <=> other.permalink
    end

    include Comparable

    def inspect
      "#<#{self.class} #{permalink}>"
    end

  end


  class File
    include FileInterface

    @types = {}

    # Registers a new file type which can then be used by {.create}.
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

    # Regular expression to match the text of the file, contains two match
    # groups; the first matches the yaml part, the second any text.
    YAML_REGEX = /\A---\n^(.*?)\n^---\n?(.*)\z/m

    attr_reader :path

    # @param site [Site] Site the file is in.
    # @param path [Pathname] Path to the file.
    def initialize(site, path)
      @site = site
      @path = path
    end

    # Reads the file, splitting it in to two parts; the yaml and the text.
    #
    # @example
    #
    #   file = File.new(site, "hello-world.md")
    #   file.read
    #   #=> ["title: Hello World\ndate:  2012-02-03",
    #   #    "Hello, world!"]
    #
    # @return [Array<String>] An array of two parts. The first is the yaml part
    #   of the file, the second is the text part.
    def read
      contents = @path.read || ""
      if match = contents.match(YAML_REGEX)
        match.to_a[1..2]
      else
        ['', contents]
      end
    end

    # @return [Hash{Symbol=>Object}] Returns the data loaded from the file's
    #   yaml frontmatter.
    def yaml
      Henshin.load_yaml read[0]
    end

    # @return [Hash{Symbol=>Object}] Returns data for templating.
    def data
      {
        url:       url,
        permalink: permalink
      }.merge(yaml)
    end

    # @return [String] Extension for the file to be written.
    def extension
      @path.extname
    end

    # @return [String] Text of the file.
    def text
      read[1]
    end

    # If the file's yaml contains the "permalink" key, the value will be used as
    # the permalink, otherwise the permalink is calculated from the file's path.
    #
    # @return [String] Absolute url to the file, including 'index.html'.
    def permalink
      if yaml.key?(:permalink)
        ::File.join(@site.url_root, yaml[:permalink])
      else
        ::File.join(@site.url_root, @path.relative_path_from(@site.root)).
          sub(@path.extname, extension)
      end
    end

  end
end
