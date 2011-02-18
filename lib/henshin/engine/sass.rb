module Henshin
 
  autoload_gem :Sass, 'sass'
  
  class Sass
    implements Engine
    
    def render(content, data)
      ::Sass::Engine.new(content, :syntax => :sass).render
    end
  end
  
  class Scss
    implements Engine
    
    def render(content, data)
      ::Sass::Engine.new(content, :syntax => :scss).render
    end
  end
  
end
