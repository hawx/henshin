module Henshin

  class Site

    attr_reader :root

    def initialize(root='.')
      @root = Pathname.new(root)

      CoffeeScriptEngine.setup
      RedcarpetEngine.setup
      SassEngine.setup
      SlimEngine.setup
    end

  end
end
