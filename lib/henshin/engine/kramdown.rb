module Henshin::Engine

  autoload_gem :Kramdown, 'kramdown'
  
  class Kramdown
    implement Henshin::Engine
    
    def render(content, data)
      content = Support::HighlightScanner.highlight(content)
      ::Kramdown::Document.new(content).to_html
    end
  end
  
end