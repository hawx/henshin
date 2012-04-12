module Henshin

  class Tag
    attr_reader :name

    def initialize(name, posts)
      @name = name || ''
      @posts = posts.find_all {|p| p.tag?(name) }
    end

    def data
      {@name => @posts.map(&:data)}
    end

    def <=>(other)
      name <=> other.name
    end

    include Comparable
  end

  class Tags

    def self.create(site, posts)
      names = posts.map(&:tags).flatten.uniq
      tags = names.map {|name| Tag.new(name, posts) }
      new(tags)
    end

    def initialize(tags)
      @tags = tags
    end

    def data
      @tags.sort.inject({}) {|a,e| a.merge(e.data) }
    end
  end

end
