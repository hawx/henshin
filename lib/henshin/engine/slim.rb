require 'henshin/engine/support/highlighter'

module Henshin::Engine

  autoload_gem :Slim, 'slim'
  
  class Slim
    implement Henshin::Engine
    
    def render(content, data)
      t = ::Slim::Template.new { content }
      t.render(MagicHash.new(data), {})
    end
    
    class HighlightEngine < ::Slim::EmbeddedEngine
      def on_slim_embedded(engine, *body)
        lines = collect_text(body).split("\n")
        lang = lines[0][1..-1]
        code = lines[1..-1].join("\n")
        [:static, Support::Highlighter.highlight(code, lang)]
      end
    end
    
    ::Slim::EmbeddedEngine.register(:highlight, HighlightEngine)
  end
end