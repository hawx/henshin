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
        'posts' => @posts.collect {|i| i.to_hash}
      }
    end
    
    
    def inspect
      "#<Tag:#{@name}>"
    end
    
  end
end