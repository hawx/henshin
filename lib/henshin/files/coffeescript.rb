module Henshin

  # Uses {CoffeeScriptEngine} to render text.
  class CoffeeScriptFile < File

    # @return [String] Javascript compiled from the coffeescript source.
    def text
      Tilt[:coffee].new(nil, nil, @site.config[:coffee]) { super }.render
    end
  end

  File.register /\.coffee/, CoffeeScriptFile

end
