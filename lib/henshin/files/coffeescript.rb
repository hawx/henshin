module Henshin

  # Uses {CoffeeScriptEngine} to render text.
  class CoffeeScriptFile < File

    # @return [String] Javascript compiled from the coffeescript source.
    def text
      CoffeeScriptEngine.render super
    end

    def extension
      '.js'
    end
  end

  File.register '.coffee', CoffeeScriptFile

end
