module Henshin
  class StandardPlugin
    # the main class for plugins to inherit from eg
    #
    #   class MyPlugin < NoName::StandardPlugin
    #
    # or it can inherit a subclass from below
    
    # This is quite useful if a dummy plugin is needed
    
    attr_accessor :extensions, :config
    
    def initialize
      @extensions = []
      @config = {}
    end
  end
  
  class HTMLGenerator < StandardPlugin
    # a plugin which returns html
    
    def generate( content )
      #return html
    end
  end
  
  class CSSGenerator < StandardPlugin
    # a plugin which returns css
    
    def generate( content )
      #return css
    end
  end
  
  class JSGenerator < StandardPlugin
    # a plugin which returns javascript
    
    def generate( content )
      #return javascript
    end
  end
  
  class LayoutParser < StandardPlugin
    # a plugin which returns html
    # given a layout and data to insert
    
    def generate( layout, data )
      #return html
    end
  end
  
end