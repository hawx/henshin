module Henshin
  class StandardPlugin
    # the main class for plugins to inherit from eg
    #
    #   class MyPlugin < NoName::StandardPlugin
    #
    # or it can inherit a subclass from below
    #
    # This is quite useful if a dummy plugin is needed
    
    attr_accessor :extensions, :config
    
    def initialize
      # inputs are the file types it will take
      # output should be the type it creates
      @extensions = {:input => [],
                     :output => ''}
      @config = {}
    end
  end
  
  class Generator < StandardPlugin
    # a plugin which returns anything*
    
    def generate( content )
      # return stuff
    end
  end
  
  class LayoutParser < StandardPlugin
    # a plugin which returns anything*
    # given a layout and data to insert
    
    def generate( layout, data )
      # return stuff
    end
  end
  
end