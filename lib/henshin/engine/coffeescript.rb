class Henshin::Engine

  autoload_gem :CoffeeScript, 'coffee-script'
  
  class CoffeeScript < Henshin::Engine
    register :coffeescript
    
    def render(content, data)
      ::CoffeeScript.compile(content)
    end
  end
end
