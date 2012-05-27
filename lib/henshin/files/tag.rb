module Henshin

  class Tag < AbstractFile

    TEMPLATE = 'tag_page'

    attr_reader :name

    def initialize(name, site)
      @name  = name
      @site  = site
    end

    def posts
      posts = @site.posts
      posts.find_all {|p| p.has_tag?(name) }
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
        posts:     posts.map(&:data)
      }.merge(basic_data)
    end

    def text
      @site.template TEMPLATE, data
    end

    def <=>(other)
      name <=> other.name
    end

    include Comparable

    def writeable?
      @site.has_template? TEMPLATE
    end

  end
end
