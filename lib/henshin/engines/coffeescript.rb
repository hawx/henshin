require 'coffee-script'

module Henshin

  # Engine which renders coffeescript using the coffee-script gem.
  # @see http://github.com/josh/ruby-coffee-script
  class CoffeeScriptEngine < Engine

    def self.render(text, data={})
      CoffeeScript.compile text
    end
  end
end
