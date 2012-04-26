require 'slim'

module Henshin

  # An engine renders text, using any data provided.
  class Engine

    # Sets up any settings for the engine. *Must* be called before {.render}
    # is used.
    #
    # @param opts [Hash]
    def setup(opts={})
      @opts = opts
    end

    # Renders the text passed using the data given.
    #
    # @param text [String]
    # @param data [Hash]
    def render(text, data={})
      text
    end
  end

  module Engines
    extend self

    @engines = {}

    # Registers a new engine so that it can be used to render text.
    #
    # @param name [Symbol] Name to refer to the engine with
    # @param engine [Engine] Engine being registered
    def register(name, engine)
      @engines[name] = engine.new
    end

    # Finds the engine with the name given, if not found returns an instance of
    # {Engine}.
    #
    # @param name [Symbol] Name of engine to find
    # @return [Engine] Returns an instance of Engine/an Engine subclass
    def find(name)
      @engines.fetch name, Engine.new
    end

    # Renders some text and data with the named engine.
    #
    # @param name [Symbol] Name of Engine to use
    # @param text [String] Text to render
    # @param data [Hash] Data to use when rendering
    # @return [String] Rendered text
    def render(name, text, data={})
      find(name).render(text, data)
    end

    # Sets up all registered engines using the configuration passed.
    #
    # @param config [Hash] See individual engines for options allowed. The
    #   config for an engine should be under the registered name.
    def setup(config)
      each do |name, engine|
        engine.setup config.fetch(name, {})
      end
    end

    # Iterates through each registered engine yielding the name and engine
    # instance to the block given.
    #
    # @yield [Symbol, Engine]
    def each
      @engines.each do |engine|
        yield engine
      end
    end
  end

end
