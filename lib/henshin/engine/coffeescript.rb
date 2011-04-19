module Henshin::Engine

  autoload_gem :CoffeeScript, 'coffee-script'
  
  class CoffeeScript
    implement Henshin::Engine
    
    def render(content, data)
      ::CoffeeScript.compile(content)
    end
  end
end

Henshin.register_engine :coffeescript, Henshin::Engine::CoffeeScript