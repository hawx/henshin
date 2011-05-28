require 'henshin/engine/support/highlighter'

class Henshin::Engine
  
  autoload_gem :Maruku, 'maruku'
  
  class Maruku < Henshin::Engine
    register :maruku
    
    def render(content, data)
      content = Support::HighlightScanner.highlight(content)
      ::Maruku.new(content).to_html
    end
  end
end
