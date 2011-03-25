module Henshin

  autoload_gem :Slim, 'slim'
  
  class Slim
    implement Engine
    
    def render(content, data)
      t = ::Slim::Template.new { content }
      t.render(MagicBox.new(data), data)
    end
    
    class MagicBox
      def initialize(hash)
        hash.each do |k, v|
          instance_variable_set("@#{k}", v)
        end
      end
    end
    
    class HighlightEngine < ::Slim::EmbeddedEngine
      def on_slim_embedded(engine, *body)
        lines = collect_text(body).split("\n")
        lang = lines[0][1..-1]
        code = lines[1..-1].join("\n")
        [:static, Henshin::Highlighter.highlight(code, lang)]
      end
    end
    
    ::Slim::EmbeddedEngine.register(:highlight, HighlightEngine)
  end
end