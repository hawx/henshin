module Henshin

  autoloads :RedCloth, 'redcloth'
  
  class RedClothEngine
    def make(content, data)
      RedCloth.new(content).to_html
    end
  end
  
end
