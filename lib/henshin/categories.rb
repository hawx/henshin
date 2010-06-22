module Henshin
  class Category
  
    attr_accessor :name, :posts
    
    def initialize( name )
      @name = name
      @posts = []
    end
    
    def to_hash
      hash = {
        'name' => @name,
        'posts' => @posts.sort.collect {|i| i.to_hash},
        'url' => self.url
      }
    end
    
    def url
      "/categories/#{@name.slugify}/"
    end
    
    
    def inspect
      "#<Category:#{@name}>"
    end
    
  end
end