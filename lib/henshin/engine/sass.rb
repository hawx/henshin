class Henshin::Engine
 
  #autoload_gem :Sass, 'sass'
  require 'sass' # for some reason .autoload_gem is being annoying
  
  class Sass < Henshin::Engine
    register :sass
    
    def render(content, data)
      source = data['site']['source'].to_s rescue nil
      ::Sass::Engine.new(
        content, 
        :syntax => :sass,
        :load_paths => [source]
      ).render
    end
  end
  
  class Scss < Henshin::Engine
    register :scss
    
    def render(content, data)
      source = data['site']['source'].to_s rescue nil
      ::Sass::Engine.new(
        content, 
        :syntax => :scss,
        :load_paths => [source]
      ).render
    end
  end
  
end
