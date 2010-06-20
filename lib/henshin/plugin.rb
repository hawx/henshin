module Henshin
  class StandardPlugin
    # the main class for plugins to inherit from eg
    #
    #   class MyPlugin < NoName::StandardPlugin
    #
    # or it can (and should) inherit a subclass from below
    
    attr_accessor :extensions, :config
    
    # Defaults = {}
    
    def initialize
      # inputs are the file types it will take
      # output should be the type it creates
      @extensions = {:input => [],
                     :output => ''}
    end
    
    def configure( override )
      if Defaults
        if override 
          @config = Defaults.merge(override) 
        else
          @config = Defaults
        end
      elsif override
        @config = override
      end
    end
    
    def <=>(other)
      self.priority <=> other.priority
    end
    
    # Uncomment to have the plugin loaded
    # Henshin.register! self, :standard_plugin
  end
  
  class Generator < StandardPlugin
    # a plugin which returns anything*
    
    def generate( content )
      # return string
    end
    
    # Uncomment to have the plugin loaded
    # Henshin.register! self, :generator
  end
  
  class LayoutParser < StandardPlugin
    # a plugin which returns anything*
    
    # given a layout and data to insert
    def generate( layout, data )
      # return string
    end
    
    # Uncomment to have the plugin loaded
    # Henshin.register! self, :generator
  end
  
end