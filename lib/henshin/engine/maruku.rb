require 'henshin/engine/support/highlighter'

module Henshin::Engine
  
  autoload_gem :Maruku, 'maruku'
  
  class Maruku
    implement Henshin::Engine
    
    def render(content, data)
      content = Support::HighlightScanner.highlight(content)
      ::Maruku.new(content).to_html
    end
  end
end

Henshin.register_engine :maruku, Henshin::Engine::Maruku