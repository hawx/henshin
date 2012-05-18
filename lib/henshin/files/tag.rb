module Henshin

  class Tag < AbstractFile

    attr_reader :name

    def initialize(name, site)
      @name  = name
      @site  = site
    end

    def posts
      @site.posts.find_all {|p| p.tag?(name) }
    end

    def path
      Path @site.url_root, "/tag/#{@name.slugify}/index.html"
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

    def <=>(other)
      name <=> other.name
    end

    include Comparable

    def writeable?
      @site.templates.any? {|i| i.name == 'tag_page' }
    end

  end
end
