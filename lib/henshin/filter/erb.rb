module Henshin
  
  autoloads :ERB, 'erb'
  
  class ErbEngine
    def make(content, data)
      ERB.new(content).run(data)
    end
  end
  
end
