module Henshin

  class Tag < AbstractFile

    attr_reader :name

    def initialize(name, posts, site)
      @name = name || ''
      @posts = posts.find_all {|p| p.tag?(name) }
      @site = site
    end

    def path
      Path @site, "/tag/#{@name.slugify}/index.html"
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
