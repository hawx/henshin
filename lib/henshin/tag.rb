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
      template = @site.template!('tag_page')

      if template
        file_data = @site.data.merge(data.merge(:tag => @posts.map(&:data)))
        SlimEngine.render template.text, file_data
      end
    end

    def permalink
      "/tag/#{@name.slugify}/index.html"
    end

    def url
      "/tag/#{@name.slugify}/"
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
      '/tag/index.html'
    end

    def url
      '/tag/'
    end

    def write(*args)
      super(*args) if @site.template!('tag_page')
    end

    def inspect
      "#<Tags [#{@tags.map(&:name).join(', ')}]>"
    end

  end

end
