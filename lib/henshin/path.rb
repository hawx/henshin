module Henshin

  # @example
  #
  #   site = Site.new('site')
  #   site.url_root #=> #<Pathname:blog>
  #
  #   path = Path(@site, 'tag', 'code', 'index.html')
  #   path.extension   #=> 'html'
  #   path.permalink   #=> '/blog/tag/code/index.html'
  #   path.url         #=> '/blog/tag/code'
  #   path.write       #=> #<Pathname:site/build/blog/tag/code/index.html>
  #
  #   path == '/blog/tag/code/'
  #   #=> true
  #
  class Path

    def initialize(site, *path)
      @site = site
      @path = path.flatten
    end

    # @return [String] Extension of the Path
    def extension
      ::File.extname @path.last
    end

    # @return [String] Full url to Path
    def permalink
      @path.inject(@site.url_root, :+).to_s
    end

    # @return [String] Pretty url to Path
    def url
      permalink.sub /index\.html$/, ''
    end

    # @param dir [Pathname] Path site is being built to
    # @return [Pathname] Path to write to
    def write(dir)
      @path.inject(dir, :+)
    end

    def to_s
      @path.inject(Pathname.new('.'), :+).to_s
    end

    def << other
      @path << other
      self
    end

    def == other
      return false unless other.is_a?(Path)

      self.to_s == other.to_s
    end

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
