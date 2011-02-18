module Henshin
  
  autoload_gem :Maruku, 'maruku'
  
  class Maruku
    implements Engine
    
    def render(content, data)
      ::Maruku.new(content).to_html
    end
  end
  
end
