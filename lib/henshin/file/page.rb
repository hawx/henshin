module Henshin
  class Page < Henshin::File
      
    def output
      'html'
    end
    
    def key
      :page
    end
      
  end
end