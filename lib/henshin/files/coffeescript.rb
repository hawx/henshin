module Henshin

  class CoffeeScriptFile < File
    def text
      CoffeeScriptEngine.render super
    end

    def extension
      '.js'
    end
  end

  File.register '.coffee', CoffeeScriptFile

end
