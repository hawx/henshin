module Henshin

  # @example
  #
  #   path = Path('/blog', 'tag', 'code', 'index.html')
  #   path.extension   #=> 'html'
  #   path.permalink   #=> '/blog/tag/code/index.html'
  #   path.url         #=> '/blog/tag/code'
  #
  #   path == '/blog/tag/code/'
  #   #=> true
  #
  class Path

    # Creates a new Path instance for the site given with the path provided.
    # The path is constructed from the parts passed in.
    #
    # @param path [String, Pathname] The path to the file the Path instance
    #   refers to.
    #
    # @example
    #
    #   Path.new('/', 'folder', 'another-folder', 'file.txt')
    #   #=> #<Henshin::Path /folder/another-folder/file.txt>
    #
    def initialize(*path)
      @path = path.flatten.map {|p| Pathname.new(p) }
    end

    # @return [String] Extension of the Path
    def extension
      ::File.extname @path.last
    end

    # Returns a full url path to the location specified.
    #
    # @return [String] Full url to Path
    # @example
    #
    #   Path('/', 'blog', '2011', 'hello-world', 'index.html').permalink
    #   #=> '/blog/2011/hello-world/index.html'
    #
    def permalink
      url = @path.inject(:+).to_s

      Henshin.local? ? url[1..-1] : url
    end

    alias_method :to_s, :permalink

    # Returns the url without +index.html+ at the end if possible.
    #
    # @return [String] Pretty url to Path
    # @example
    #
    #   Path('/', 'blog', '2011', 'hello-world', 'index.html').permalink
    #   #=> '/blog/2011/hello-world/'
    #
    def url
      if Henshin.local?
        permalink
      else
        permalink.sub /index\.html$/, ''
      end
    end

    # Appends a path onto the Path.
    #
    # @param other [String, Pathname]
    # @return [Path]
    # @example
    #
    #   path = Path('folder')
    #   path << 'another' << 'file.txt'
    #   path #=> #<Henshin::Path folder/another/file.txt>
    #
    def << other
      @path << other
      self
    end

    # Checks (strictly) whether a Path instance is equal to another. This
    # compares them using {#to_s}, so both Paths will need to have the same
    # root _and_ path to be equal.
    #
    # @param other [Path]
    # @example
    #
    #   a = Path 'a', 'test.txt'
    #   b = Path 'b', 'test.txt'
    #
    #   a == b
    #   #=> false
    #
    #   a == Path('a', 'test.txt')
    #   #=> true
    #
    def == other
      return false unless other.is_a?(Path)
      self.to_s == other.to_s
    end

    # Checks (loosely) whether this Path instance is equal to the given
    # argument. The argument can be another Path instance or a String, in which
    # case the String is checked for equality against the {#url} and
    # {#permalink}.
    #
    # @param other [Path, String]
    # @example
    #
    #   index = Path '/blog', 'index.html'
    #   index.permalink #=> '/blog/index.html'
    #   index.url #=> '/blog/'
    #
    #   index === '/blog/index.html'
    #   index === '/blog/'
    #   index === '/blog'
    #
    def === other
      case other
      when String
        url == other || url[0..-2] == other || permalink == other
      when Path
        self == other
      else
        false
      end
    end

    def inspect
      "#<#{self.class} #{to_s}>"
    end

  end
end

module Kernel

  # @see Henshin::Path#initialize
  def Path(*args)
    Henshin::Path.new(*args)
  end
end
