module Henshin

  require 'tilt'
  autoload_gem :Markaby, 'markaby'
  
  class Markaby
    implement Engine
    
    # Markaby itself seems to be broken!
    
    def render(content, data)
      mab = ::Markaby::Builder.new
      mab.class_eval(content)
    end
    
    # highlighting !
  end
end