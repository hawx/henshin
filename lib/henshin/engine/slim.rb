require 'henshin/engine/support/highlighter'

class Henshin::Engine

  autoload_gem :Slim, 'slim'
  
  class Slim < Henshin::Engine
    register :slim
    
    def render(content, data)
      t = ::Slim::Template.new { content }
      t.render(MagicHash.new(data), {})
    end
    
    # This uses a private API so may break in the future!
    class HighlightEngine < ::Slim::EmbeddedEngine
      def on_slim_embedded(engine, *body)
        lines = body.map { |i|
          collect_text(i).split("\n")
        }.flatten
        
        if lines.empty?
          [:static, ""]
        else
          lang = lines[0][1..-1]
          code = lines[1..-1].join("\n")
          [:static, Support::Highlighter.highlight(code, lang)]
        end
      end
    end
    
    ::Slim::EmbeddedEngine.register(:highlight, HighlightEngine)
  end
end
