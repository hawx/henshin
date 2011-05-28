require 'henshin/engine/support/highlighter'

class Henshin::Engine
  
  autoload_gem :RDiscount, 'rdiscount'
  
  class RDiscount < Henshin::Engine
    register :rdiscount
    
    def render(content, data)
      content = Support::HighlightScanner.highlight(content)
      ::RDiscount.new(content).to_html
    end
  end
end
