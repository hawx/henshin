require 'set'

module Henshin

  module FileAttributes

    def requires(*keys)
      @required ||= Set.new
      @required  += keys
    end

    def required
      @required || Set.new
    end

    def template(name)
      @template = name
    end

    def default_template
      @template
    end

  end


  # @abstract You will want to implement {#data}, {#text} and {#path}.
  #
  # This class implements all the functionality that is required to build or
  # serve a file. AbstractFile instances do not relate to a file in the file
  # system, use File in this case.
  class AbstractFile

    include  Helpers, Comparable
    extend   FileAttributes

    attr_reader :site

    def initialize(site)
      @site = site
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

    # @return [String] Extension for the file to be written.
    def extension
      path.extension
    end

    # Writes the file.
    #
    # @param writer [#write] Object which is able to write text to a path.
    def write(writer)
      return unless writeable?
      start = Time.now if Henshin.profile?
      writer.write Pathname.new(permalink.sub(/^\//, '')), text
      if Henshin.profile?
        UI.wrote permalink, (Time.now - start)
      else
        UI.wrote permalink
      end
    rescue => e
      Error.prettify("Error writing #{inspect}", e)
    end

    # Compares the files based on their permalinks.
    #
    # @param other [File]
    def <=>(other)
      permalink <=> other.permalink
    end

    def inspect
      "#<#{self.class} #{permalink}>"
    end

    private

    # @return Whether this file should be written.
    def writeable?
      true
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

    @types = []
    @applies = []

    # Registers a new file type which can then be used by {.create}.
    #
    # @param match [#match] Extension to associate file type with
    # @param klass [File] Subclass of File
    def self.register(match, klass)
      @types.unshift [match, klass]
    end

    def self.apply(match, mod)
      @applies.unshift [match, mod]
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

    # Allow yaml attributes to be accessed in templates.
    def method_missing(sym, *args, &block)
      if yaml.key?(sym)
        yaml[sym]
      else
        nil
      end
    end

    attr_accessor :template

    def yield
      text
    end

    # @return [String] Text of the file.
    def text
      read[1]
    end

    # @return [Path] If a permalink has been set in the yaml frontmatter uses
    #   that, otherwise uses the path to the file.
    def path
      if yaml.key?(:permalink)
        Path @site.root, yaml[:permalink]

      else
        rel = @path

        if @path.same_type?(@site.source)
          rel = @path.relative_path_from(@site.source)
        end

        if @path.basename.to_s.count('.') == 1
          Path @site.root, rel
        else
          ext  = @path.extname
          file = rel.to_s[0..-ext.size-1]
          Path @site.root, file
        end
      end
    end

    private

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
      loaded = Henshin.load_yaml read[0]

      singleton_class.ancestors.find_all {|klass|
        klass.singleton_class.include?(FileAttributes)

      }.map {|klass|
        klass.required.to_a

      }.flatten.reject {|key|
        respond_to?(key) || loaded.key?(key)

      }.each {|key|
        UI.fail(inspect + " requires #{key}.")
      }

      loaded
    end

  end
end
