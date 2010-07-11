module Henshin

  class Tags < Array
  
    attr_accessor :site
    
    def initialize(site)
      @site = site
    end
    
    # Overwriten method so that adding a post will add the post
    #  to each tag in the array as needed
    #
    # @param [Post]
    def <<(post)
      return nil unless post.data['tags']
      post.data['tags'].each do |t|
        # check if tag already exists
        unless self.map{|i| i.name}.include?(t)
          super Henshin::Tag.new(t, @site)
        end
        i = self.find_index {|i| i.name == t}
        self[i].posts << post
      end
    end
    
    # Turns each tag in the array to a hash for the layout parser
    def to_hash
      r = []
      self.each do |i|
        r << i.to_hash
      end
      r
    end
    
    # @return [String] permalink for the tag index
    def permalink
      File.join(@site.base, "tags/index.html")
    end
    
    # @return [String] base url for tags
    def url
      File.join(@site.base, "tags")
    end
    
    # @see Categories#fake_write_path
    def fake_write_path
      @site.root + self.permalink[1..-1]
    end
    
    # Writes the tag index and calls Tag#write for each tag
    def write
      if @site.layouts['tag_index']
        page = Gen.new(self.fake_write_path, @site)
        page.read
        page.data['layout'] = @site.layouts['tag_index']
        
        page.render
        page.write
      end
      
      if @site.layouts['tag_page']
        self.each {|tag| tag.write }
      end
    end
    
  end

  class Tag
  
    attr_accessor :name, :posts, :site
    
    def initialize(name, site)
      @name = name
      @posts = []
      @site = site  
    end
    
    def to_hash
      hash = {
        'name' => @name,
        'posts' => @posts.sort.collect {|i| i.to_hash},
        'url' => self.url
      }
    end
    
    # @return [String] permalink for the tag
    def permalink
      "/tags/#{@name.slugify}/index.html"
    end
    
    # @return [String] url for the tag
    def url
      "/tags/#{@name.slugify}/"
    end

    # @see Categories#fake_write_path
    def fake_write_path
      @site.root + self.permalink[1..-1]
    end
    
    def write
      payload = {:name => 'tag', :payload => self.to_hash}
      page = Gen.new(self.fake_write_path, @site, payload)
      page.read
      page.data['layout'] = @site.layouts['tag_page']
      
      page.render
      page.write
    end
    
    def inspect
      "#<Tag:#{@name}>"
    end
    
  end
end