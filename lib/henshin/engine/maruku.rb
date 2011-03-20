module Henshin
  
  autoload_gem :Maruku, 'maruku'
  
  class Maruku
    implement Engine
    
    def render(content, data)
      content = Henshin::HighlightScanner.highlight(content)
      ::Maruku.new(content).to_html
    end
  end
  
end
