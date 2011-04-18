require 'henshin/engine/support/highlighter'

module Henshin::Engine
  
  autoload_gem :RDiscount, 'rdiscount'
  
  class RDiscount
    implement Henshin::Engine
    
    def render(content, data)
      content = Support::HighlightScanner.highlight(content)
      ::RDiscount.new(content).to_html
    end
  end
  
end
