module Henshin
 
  #autoload_gem :Sass, 'sass'
  require 'sass' # for some reason .autoload_gem is being annoying
  
  class Sass
    implements Engine
    
    def render(content, data)
      source = data['site']['source']
      ::Sass::Engine.new(
        content, 
        :syntax => :sass,
        :load_paths => [source.to_s]
      ).render
    end
  end
  
  class Scss
    implements Engine
    
    def render(content, data)
      source = data['site']['source']
      ::Sass::Engine.new(
        content, 
        :syntax => :scss,
        :load_paths => [source.to_s]
      ).render
    end
  end
  
end
