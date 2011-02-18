module Henshin

  autoload_gem :Liquid, 'liquid'
  
  class Liquid
    implements Engine
    
    def render(content, data)
      ::Liquid::Template.parse(content).render(data)
    end
  end
  
end
