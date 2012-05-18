module Henshin

  class Tags < AbstractFile

    def self.create(site, posts)
      names = posts.map(&:tags).flatten.uniq
      tags = names.map {|name| Tag.new(name, site) }
      new(site, tags)
    end

    def initialize(site, tags)
      @site = site
      @tags = tags
    end

    def path
      Path @site.url_root, '/tag/index.html'
    end

    def text
      @site.template!('tag_index').template(self)
    end

    def files
      @tags.sort
    end

    def writeable?
      @site.templates.any? {|i| i.name == 'tag_page' }
    end

    def inspect
      "#<Tags [#{@tags.map(&:name).join(', ')}]>"
    end

  end
end
