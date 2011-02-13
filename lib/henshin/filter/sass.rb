module Henshin
 
  autoloads :Sass, 'sass'
  
  class SassEngine
    def make(content, data)
      Sass::Engine.new(content, :syntax => :sass).render
    end
  end
  
  class ScssEngine
    def make(content, data)
      Sass::Engine.new(content, :syntax => :scss).render
    end
  end
  
end
