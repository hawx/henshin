require 'slim'

module Henshin

  # An engine renders text, using any data provided.
  class Engine

    # Sets up any settings for the engine. *Must* be called before {.render}
    # is used.
    #
    # @param opts [Hash]
    def self.setup(opts={})
      @opts = opts
    end

    # Renders the text passed using the data given.
    #
    # @param text [String]
    # @param data [Hash]
    def self.render(text, data={})

    end
  end
end
