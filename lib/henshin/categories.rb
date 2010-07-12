module Henshin
  
  # Categories is essentially the same as tags, but with two differences
  # 1) writes to '/categories/'
  # 2) each post has only one category, if any
  #
  # But because of the way Tags#<< (it calls super!) works I had to 
  # rewrite it almost, maybe would be better if they both had a commom
  # ancestor which worked for both implementations
  #
  class Categories < Array
    
    attr_accessor :site
    
    def initialize(site)
      @site = site
    end
    
    # Adds the given post to the correct category object in the array
    # or creates the category and adds the post to that
    #
    # @param [Post] post to be added
    def <<(post)
      return nil unless post.data['category']
      c = post.data['category']

      unless self.map{|i| i.name}.include?(c)
        super Henshin::Category.new(c, @site)
      end
      i = self.find_index {|i| i.name == c}
      self[i].posts << post
    end
    
    # Converts the categories to a hash for use in a layout parser
    def to_hash
      r = []
      self.each do |i|
        r << i.to_hash
      end
      r
    end
    
    # @return [String] permalink for category index
    def permalink
      File.join(@site.base, "categories/index.html")
    end
    
    # @return [String] base url for categories
    def url
      File.join(@site.base, "categories")
    end
    
    # Need a fake path where the file would have been so as to 
    # trick the gen into constructing the correct paths
    #
    # @return [Pathname] the path for the gen
    def fake_write_path
      @site.root + self.permalink[1..-1]
    end
    
    # Writes the category index, then writes the individual
    # category pages
    def write
      if @site.layouts['category_index']
        page = Gen.new(self.fake_write_path, @site)
        page.read
        page.data['layout'] = @site.layouts['category_index']
        
        page.render
        page.write
      end
      if @site.layouts['category_page']
        self.each {|category| category.write }
      end
    end
    
  end
  
  # @see Tag
  class Category
    
    attr_accessor :name, :posts, :site
    
    def initialize(name, site)
      @name = name
      @posts = []
      @site = site
    end
    
    # Converts the category to a hash
    def to_hash
      hash = {
        'name' => @name,
        'posts' => @posts.sort.collect {|i| i.to_hash},
        'url' => self.url
      }
    end
    
    # @return [String] permalink for the category
    def permalink
      File.join(@site.base, "categories/#{@name.slugify}/index.html")
    end
    
    # @return [String] url for the category
    def url
      File.join(@site.base, "categories/#{@name.slugify}")
    end
    
    # @see Categories#fake_write_path
    def fake_write_path
      @site.root + self.permalink[1..-1]
    end
    
    # Writes the category page
    def write
      payload = {:name => 'category', :payload => self.to_hash}
      page = Gen.new(self.fake_write_path, @site, payload)
      page.read
      page.data['layout'] = @site.layouts['category_page']
      
      page.render
      page.write
    end
    
    def inspect
      "#<Category:#{@name}>"
    end
    
  end
end