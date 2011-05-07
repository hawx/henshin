module Henshin

  # A binary file, image, archive, audio, etc...
  class Binary < Henshin::File
  
    def readable?
      false
    end
    
    def layoutable?
      false
    end
    
    def renderable?
      false
    end
  
  end
end