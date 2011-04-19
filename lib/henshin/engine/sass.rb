module Henshin::Engine
 
  #autoload_gem :Sass, 'sass'
  require 'sass' # for some reason .autoload_gem is being annoying
  
  class Sass
    implement Henshin::Engine
    
    def render(content, data)
      source = data['site']['source'].to_s rescue nil
      ::Sass::Engine.new(
        content, 
        :syntax => :sass,
        :load_paths => [source]
      ).render
    end
  end
  
  class Scss
    implement Henshin::Engine
    
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

Henshin.register_engine :sass, Henshin::Engine::Sass
Henshin.register_engine :scss, Henshin::Engine::Scss
