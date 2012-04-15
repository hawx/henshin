require 'sass'

module Henshin

  # Engine which renders sass using the sass gem.
  # @see http://sass-lang.com
  class SassEngine < Engine

    DEFAULTS = {
      :load_paths => ['.', 'assets/style']
    }

    def self.setup(opts={})
      @opts = DEFAULTS.merge(opts)
    end

    def self.render(text, data={})
      Sass::Engine.new(text, @opts).render
    end
  end
end
