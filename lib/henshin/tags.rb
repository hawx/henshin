module Henshin
  class Tag < Gen
  
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
  
  end
end