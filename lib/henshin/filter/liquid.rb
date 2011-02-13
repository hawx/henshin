module Henshin

  autoloads :Liquid, 'liquid'
  
  class LiquidEngine
    def make(content, data)
      Liquid::Template.parse(content).render(data)
    end
  end
  
end
