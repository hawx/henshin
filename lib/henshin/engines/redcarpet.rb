require 'redcarpet'

module Henshin

  # Engine which renders markdown using the redcarpet gem.
  # @see http://github.com/tanoku/redcarpet
  class RedcarpetEngine < Engine

    DEFAULTS = {
      :no_intra_emphasis  => true,
      :fenced_code_blocks => true,
      :strikethrough      => true,
      :superscript        => true
    }

    def self.setup(opts={})
      opts = DEFAULTS.merge(opts)
      @renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, opts)
    end

    def self.render(text, data={})
      @renderer.render(text).gsub('<code class="ruby">', '<code class="brush: ruby">')
    end
  end
end
