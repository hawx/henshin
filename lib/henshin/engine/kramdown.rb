module Henshin

  autoload_gem :Kramdown, 'kramdown'
  
  class Kramdown
    implement Engine
    
    def render(content, data)
      content = Henshin::HighlightScanner.highlight(content)
      ::Kramdown::Document.new(content).to_html
    end
  end
  
end