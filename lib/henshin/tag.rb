module Henshin

  class Tag < File
    attr_reader :name

    def initialize(name, posts, site)
      @name = name || ''
      @posts = posts.find_all {|p| p.tag?(name) }
      @site = site
    end

    def data
      {
        :title => @name,
        @name => @posts.map(&:data)
      }
    end

    def text
      template = @site.template!('tag_page')

      if template
        file_data = @site.data.merge(data.merge(:tag => @posts.map(&:data)))
        SlimEngine.render template.text, file_data
      end
    end

    def permalink
      "/tag/#{@name.slugify}/index.html"
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

  class Tags < Array

    def self.create(site, posts)
      names = posts.map(&:tags).flatten.uniq
      tags = names.map {|name| Tag.new(name, posts, site) }
      new(tags)
    end

    def data
      self.sort.inject({}) {|a,e| a.merge(e.data) }
    end
  end

end
