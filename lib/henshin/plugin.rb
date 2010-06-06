module Henshin
  class StandardPlugin
    # the main class for plugins to inherit from eg
    #
    #   class MyPlugin < NoName::StandardPlugin
    #
    # or it can (and should) inherit a subclass from below
    
    attr_accessor :extensions, :config
    
    def initialize
      # inputs are the file types it will take
      # output should be the type it creates
      @extensions = {:input => [],
                     :output => ''}
      @config = {}
    end
    
    # def configure( override )
      # setup the plugin
    # end
    
    # Uncomment to have the plugin loaded
    # Henshin.register! self
  end
  
  class Generator < StandardPlugin
    # a plugin which returns anything*
    
    def generate( content )
      # return string
    end
    
    # Uncomment to have the plugin loaded
    # Henshin.register! self
  end
  
  class LayoutParser < StandardPlugin
    # a plugin which returns anything*
    
    # given a layout and data to insert
    def generate( layout, data )
      # return string
    end
    
    # Uncomment to have the plugin loaded
    # Henshin.register! self
  end
  
end