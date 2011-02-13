module Henshin
  
  autoloads :Maruku, 'maruku'
  
  class MarukuEngine
    def make(content, data)
      Maruku.new(content).to_html
    end
  end
  
end
