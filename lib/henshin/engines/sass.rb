require 'sass'

module Henshin

  # Engine which renders sass using the sass gem.
  #
  # @example
  #
  #   SassEngine.setup
  #   # then later on...
  #   SassEngine.render "body\n  color: red"
  #   #=> "..."
  #
  # @see http://sass-lang.com
  class SassEngine < Engine

    def setup(opts={})
      @opts = opts
    end

    def render(text, data={})
      Sass::Engine.new(text, @opts).render
    end
  end

  Engines.register :sass, SassEngine

end
