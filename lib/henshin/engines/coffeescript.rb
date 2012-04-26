require 'coffee-script'

module Henshin

  # Engine which renders coffeescript using the coffee-script gem.
  #
  # @example
  #
  #   CoffeeScriptEngine.setup
  #   # then later on...
  #   CoffeeScriptEngine.render "sq = (x) -> x * x"
  #   #=> "..."
  #
  # @see http://github.com/josh/ruby-coffee-script
  class CoffeeScriptEngine < Engine

    def render(text, data={})
      CoffeeScript.compile text
    end
  end

  Engines.register :coffee, CoffeeScriptEngine

end
