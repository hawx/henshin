module Henshin
  
  autoloads :CoffeeScript, 'coffee-script'
  
  class CoffeeScriptEngine
    def make(content, data)
      CoffeeScript.compile(content)
    end
  end
  
end
