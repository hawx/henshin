require 'henshin/engine/support/highlighter'

class Henshin::Engine

  autoload_gem :Kramdown, 'kramdown'
  
  class Kramdown < Henshin::Engine
    register :kramdown
    
    def render(content, data)
      content = Support::HighlightScanner.highlight(content)
      ::Kramdown::Document.new(content).to_html
    end
  end
end

Henshin.register_engine :kramdown, Henshin::Engine::Kramdown
