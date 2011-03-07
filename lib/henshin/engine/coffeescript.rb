module Henshin

  autoload_gem :CoffeeScript, 'coffee-script'
  
  class CoffeeScript
    implements Engine
    
    def render(content, data)
      ::CoffeeScript.compile(content)
    end
  end
  
end