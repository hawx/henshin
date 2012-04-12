require 'coffee-script'
require 'redcarpet'
require 'sass'
require 'slim'

module Henshin

  # An engine renders text, using any data provided if necessary.
  class Engine

    # Sets up any settings for the engine.
    #
    # @param opts [Hash]
    def self.setup(opts={})

    end

    # Renders the text passed using the data given.
    #
    # @param text [String]
    # @param data [Hash]
    def self.render(text, data={})

    end
  end

  class CoffeeScriptEngine < Engine

    def self.render(text, data={})
      CoffeeScript.compile text
    end
  end

  class RedcarpetEngine < Engine

    DEFAULTS = {
      :no_intra_emphasis  => true,
      :fenced_code_blocks => true,
      :strikethrough      => true,
      :superscript        => true
    }

    # See https://github.com/tanoku/redcarpet
    def self.setup(opts={})
      opts = DEFAULTS.merge(opts)
      @renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, opts)
    end

    def self.render(text, data={})
      @renderer.render(text).gsub('<code class="ruby">', '<code class="brush: ruby">')
    end
  end

  class SassEngine < Engine

    DEFAULTS = {
      :load_paths => ['.', 'assets/style']
    }

    # See http://sass-lang.com/docs/yardoc/Sass/Engine.html
    def self.setup(opts={})
      @opts = DEFAULTS.merge(opts)
    end

    def self.render(text, data={})
      Sass::Engine.new(text, @opts).render
    end
  end

  class SlimEngine < Engine

    class ScopeObject
      def initialize(data)
        meta = (class << self; self; end)
        data.each do |k,v|
          case v
          when Hash
            meta.send(:define_method, k) { ScopeObject.new(v) }
          when Array
            meta.send(:define_method, k) { v.map {|i| ScopeObject.new(i) } }
          else
            meta.send(:define_method, k) { v }
          end
        end
      end

      def method_missing(sym, *args)
        nil
      end
    end

    # See http://slim-lang.com/docs.html#options
    def self.setup(opts={})
      @opts = opts
    end

    def self.render(text, data={})
      data = ScopeObject.new(data)
      Slim::Template.new(@opts) { text }.render(data) { data.yield }
    end
  end

end
