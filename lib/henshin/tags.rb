module Henshin
  class Tag
  
    attr_accessor :name, :posts
    
    def initialize( name )
      @name = name
      @posts = []
    end
  
  end
end