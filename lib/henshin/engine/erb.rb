module Henshin

  autoloads :ERB, 'erb'
  
  class ERB
    implements Engine
    
    def render(content, data)
      ERB.new(content).run(data)
    end
  end
  
end