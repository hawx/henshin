require 'henshin/engine/support/highlighter'
require 'redcarpet'

class Henshin::Engine

  autoload_gem :Redcarpet, 'redcarpet'

  class Redcarpet < Henshin::Engine
    register :redcarpet

    def render(content, data)
      content = Support::HighlightScanner.highlight(content)
      ::Redcarpet::Markdown.new(::Redcarpet::Render::HTML).render(content)
    end
  end
end
