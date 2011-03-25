module Henshin
  
  autoload_gem :RDiscount, 'rdiscount'
  
  class RDiscount
    implement Engine
    
    def render(content, data)
      content = Henshin::HighlightScanner.highlight(content)
      ::RDiscount.new(content).to_html
    end
  end
  
end
