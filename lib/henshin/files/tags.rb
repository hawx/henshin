module Henshin

  class Tags < AbstractFile

    TEMPLATE = 'tag_index'

    def self.create(site, posts)
      names = posts.map(&:tags)
      names.flatten!
      names.uniq!
      tags  = names.map {|name| Tag.new(name, site) }
      index = TagIndex.new(site, tags)

      new(index, tags)
    end

    def initialize(index, tags)
      @index = index
      @tags  = tags
    end

    def find_by_name(*names)
      find_all {|tag| names.include?(tag.name) }
    end

    def files
      @tags.sort + [@index]
    end

    def each
      @tags.sort.each do |tag|
        yield tag
      end
    end

    include Enumerable

    def inspect
      "#<Tags [#{@tags.map(&:name).join(', ')}]>"
    end

  end

  class TagIndex < AbstractFile

    TEMPLATE = 'tag_index'

    def initialize(site, tags)
      @site = site
      @tags = tags
    end

    def path
      Path @site.url_root, 'tag/index.html'
    end

    def text
      @site.template TEMPLATE, data
    end

    def writeable?
      @site.has_template? TEMPLATE
    end

  end
end
