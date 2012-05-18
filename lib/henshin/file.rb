module Henshin

  # @abstract You will want to implement {#data}, {#text} and {#path}.
  class AbstractFile

    # @return [Hash] Data for the file.
    def data
      {}
    end

    # @return [String] Text to write to the file.
    def text
      ""
    end

    # @return [Path] Path to the file.
    def path

    end

    # @return [String] The absolute url to the file.
    def permalink
      path.permalink
    end

    # @return [Pathname] A pretty url to the file, the permalink with
    #   'index.html' stripped from the end generally.
    def url
      path.url
    end

    # @param dir [Pathname] Path the site is being built to.
    # @return [Pathname] Path to write the file to.
    def write_path(dir)
      path.write(dir)
    end

    # @return [String] Extension for the file to be written.
    def extension
      path.extension
    end

    # @return Whether this file should be written.
    def writeable?
      true
    end

    # Writes the file.
    #
    # @param dir [Pathname] Path the site is built to.
    def write(dir)
      return unless writeable?
      Writer.write write_path(dir), text
      UI.wrote permalink
    rescue => e
      Error.prettify("Error writing #{inspect}", e)
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


  # A file physically located on the file system. A subclass of file will
  # have a @path variable with it's location. Also a factory for creating
  # instances of registered files. Instead of,
  #
  #   file = SomeFile.new(site, path)
  #
  # use,
  #
  #   File.register /pattern/, SomeFile
  #   # ...
  #   file = File.create(site, path)
  #
  class File < AbstractFile

    @types = {}
    @applies = {}

    # Registers a new file type which can then be used by {.create}.
    #
    # @param match [#match] Extension to associate file type with
    # @param klass [File] Subclass of File
    def self.register(match, klass)
      @types[match] = klass
    end

    def self.apply(match, mod)
      @applies[match] = mod
    end

    # Creates a new File, or if possible a subclass of File, depending on the
    # extension of the path given.
    #
    # @param site [Site]
    # @param path [Pathname]
    def self.create(site, path)
      klass = (@types.find {|k,v| k =~ path.to_s } || [nil, self]).last
      obj = klass.new(site, path)

      @applies.find_all {|k,v| k =~ path.to_s }.each {|_,v| obj.extend(v) }
      obj
    end

    # Regular expression to match the text of the file, contains two match
    # groups; the first matches the yaml part, the second any text.
    YAML_REGEX = /\A---\n^(.*?)\n^---\n?(.*)\z/m

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
      contents = ::File.read(@path.to_s) || ""
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

    # @return [String] Text of the file.
    def text
      read[1]
    end

    # @return [Path] If a permalink has been set in the yaml frontmatter uses
    #   that, otherwise uses the path to the file.
    def path
      Path @site.url_root, yaml.fetch(:permalink, @path.relative_path_from(@site.root))
    end

  end
end
