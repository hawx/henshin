module Henshin
  
  # Categories is essentially the same as tags, but with two differences
  #  1) writes to '/categories/'
  #  2) each post has only one category, if any
  #
  #  But because of the way Tags#<< (it calls super!) works I had to 
  #  rewrite it almost, maybe would be better if they both had a commom
  #  ancestor which worked for both implementations
  #
  class Categories < Array
    
    attr_accessor :site
    
    def initialize(site)
      @site = site
    end
    
    # Overwriten method so that adding a post will add the post
    #  to the category in the array as needed
    #
    # @param [Post]
    def <<(post)
      return nil unless post.data['category']
      c = post.data['category']

      unless self.map{|i| i.name}.include?(c)
        super Henshin::Category.new(c, @site)
      end
      i = self.find_index {|i| i.name == c}
      self[i].posts << post
    end
    
    def to_hash
      r = []
      self.each do |i|
        r << i.to_hash
      end
      r
    end
    
    # @return [String] base url for categories
    def url
      "categories/"
    end
    
    def permalink
      "categories/index.html"
    end
    
    def write
      if @site.layouts['category_index']
        t = @site.root + self.permalink
        
        category_index = Gen.new(t, @site)
        category_index.layout = @site.layouts['category_index']
        
        category_index.render
        category_index.write
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
    
    def to_hash
      hash = {
        'name' => @name,
        'posts' => @posts.sort.collect {|i| i.to_hash},
        'url' => self.url
      }
    end
    
    def url
      "categories/#{@name.slugify}/"
    end
    
    def permalink
      "categories/#{@name.slugify}/index.html"
    end
    
    def write
      t = @site.root + self.permalink
      
      payload = {:name => 'category', :payload => self.to_hash}
      category_page = Gen.new(t, @site, payload)
      category_page.layout = @site.layouts['category_page']
      
      category_page.render
      category_page.write
    end
    
    def inspect
      "#<Category:#{@name}>"
    end
    
  end
end