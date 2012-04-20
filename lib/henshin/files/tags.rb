module Henshin

  class Tags

    include FileInterface

    def self.create(site, posts)
      names = posts.map(&:tags).flatten.uniq
      tags = names.map {|name| Tag.new(name, posts, site) }
      new(site, tags)
    end

    def initialize(site, tags)
      @site = site
      @tags = tags
    end

    def text
      template = @site.template!('tag_index')

      if template
        SlimEngine.render template.text, @site.data
      end
    end

    def files
      @tags.sort
    end

    def data
      files.map(&:data)
    end

    def permalink
      "#{@site.url_root}tag/index.html"
    end

    def url
      "#{@site.url_root}tag/"
    end

    def write(*args)
      super(*args) if @site.template!('tag_page')
    end

    def inspect
      "#<Tags [#{@tags.map(&:name).join(', ')}]>"
    end

  end
end
