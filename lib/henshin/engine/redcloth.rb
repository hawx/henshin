module Henshin

  autoload_gem :RedCloth, 'redcloth'
  
  class RedCloth
    implements Engine
    
    def render(content, data)
      content = Henshin::HighlightScanner.highlight(content)
      ::RedCloth.new(content).to_html
    end
  end
  
end
