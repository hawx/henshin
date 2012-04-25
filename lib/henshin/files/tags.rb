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

    def path
      Path @site, '/tag/index.html'
    end

    def text
      @site.template!('tag_index').template(self)
    end

    def files
      @tags.sort
    end

    def find_for(name)
      files.find_all {|i| tag?(name) }.sort
    end

    def write(*args)
      super(*args) if @site.template!('tag_page')
    end

    def inspect
      "#<Tags [#{@tags.map(&:name).join(', ')}]>"
    end

  end
end
