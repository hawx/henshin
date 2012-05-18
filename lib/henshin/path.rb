module Henshin

  # @example
  #
  #   site.url_root #=> #<Pathname:blog>
  #
  #   path = Path(site.url_root, 'tag', 'code', 'index.html')
  #   path.extension   #=> 'html'
  #   path.permalink   #=> '/blog/tag/code/index.html'
  #   path.url         #=> '/blog/tag/code'
  #   path.write       #=> #<Pathname:site/build/blog/tag/code/index.html>
  #
  #   path == '/blog/tag/code/'
  #   #=> true
  #
  class Path

    # Creates a new Path instance for the site given with the path provided.
    # The path is constructed from the parts passed in.
    #
    # @param root [String, Pathname] Root folder of the path. This will usually
    #   be equal to the site's #url_root.
    # @param path [String, Pathname] The path to the file the Path instance
    #   refers to.
    #
    # @example
    #
    #   Path.new(site.url_root, 'folder', 'another-folder', 'file.txt')
    #
    def initialize(root, *path)
      @root = Pathname.new(root)
      @path = path.flatten
    end

    # @return [String] Extension of the Path
    def extension
      ::File.extname @path.last
    end

    # @return [String] Full url to Path
    def permalink
      @path.inject(@root, :+).to_s
    end

    alias_method :to_s, :permalink

    # @return [String] Pretty url to Path
    def url
      permalink.sub /index\.html$/, ''
    end

    # Appends a path onto the Path.
    #
    # @param other [String, Pathname]
    # @return [Path]
    # @example
    #
    #   path = Path '.', 'folder'
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
