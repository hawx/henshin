module Henshin
  
  autoloads :Haml, 'haml'
  
  class HamlEngine
    def make(content, data)
      Haml::Engine.new(content).render(Object.new, data)
    end
  end
  
end
