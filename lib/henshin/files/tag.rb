module Henshin

  class Tag

    include FileInterface

    attr_reader :name

    def initialize(name, posts, site)
      @name = name || ''
      @posts = posts.find_all {|p| p.tag?(name) }
      @site = site
    end

    def basic_data
      {
        title:     @name,
        url:       url,
        permalink: permalink
      }
    end

    def data
      {
        posts:     @posts.map(&:data)
      }.merge(basic_data)
    end

    def text
      @site.template!('tag_page').template(self)
    end

    def permalink
      @site.url_root + 'tag' + @name.slugify + 'index.html'
    end

    def extension
      '.html'
    end

    def <=>(other)
      name <=> other.name
    end

    include Comparable

    def write(*args)
      super(*args) if @site.template!('tag_page')
    end

  end
end
