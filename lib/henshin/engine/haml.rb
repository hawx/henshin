module Henshin
  
  autoload_gem :Haml, 'haml'
  
  class Haml
    implements Engine
    
    def render(content, data)
      ::Haml::Engine.new(content).render(Object.new, data)
    end
  end
  
end
