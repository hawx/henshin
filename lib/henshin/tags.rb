module Henshin
  class Tag
  
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
      "/tags/#{@name.slugify}/"
    end
    
    def inspect
      "#<Tag:#{@name}>"
    end
    
  end
end