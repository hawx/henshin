module Henshin

  # Uses {CoffeeScriptEngine} to render text.
  class CoffeeScriptFile < File

    # @return [String] Javascript compiled from the coffeescript source.
    def text
      Engines.render :coffee, super
    end

    def extension
      '.js'
    end
  end

  File.register /\.coffee/, CoffeeScriptFile

end
