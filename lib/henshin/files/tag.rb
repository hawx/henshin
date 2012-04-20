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
end
