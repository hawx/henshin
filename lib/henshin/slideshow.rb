# A slideshow would be interesting to do and possible by the end!

module Henshin
  class SlideShow < Base
  
    class Slide < Henshin::File
    
    end
    
    filter 'slides/*.*' => Slide
  
    render 'slides/:title.:ext' do
      
    end
  
  end
end