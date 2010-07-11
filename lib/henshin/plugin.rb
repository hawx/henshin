module Henshin
  class Plugin
   
    attr_accessor :extensions, :config, :priority
    
    def initialize(site)
      # input [Array] is a list of file extensions that this plugin can read
      # output [String] should be the type it creates
      @extensions = {:input => [],
                     :output => ''}
      
      # You can put some defaults in this
      @config = {}
      
      # The plugins are sorted based on priority, and then called in order
      # 1 is high, 5 is low
      # You could really use any number, but stick to 1 to 5
      @priority = 3
    end
    
    # Allows you to set up the plugin
    #
    # @param [Hash] override options for this specific plugin
    # @param [Hash] site options for the whole site
    def configure( override, site )
      @config.merge!(override) if override
    end
    
    # Finds all classes that subclass this particular class
    #
    # @return [Array] an array of class objects
    # @see http://www.ruby-forum.com/topic/163430 
    #   modified from the answer given here
    def self.subclasses     
      r = Henshin.constants.find_all do |c_klass| 
        if (c_klass != c_klass.upcase) && (Henshin.const_get(c_klass).is_a?(Class))
          self > Henshin.const_get(c_klass)
        else
          nil
        end
      end
      r.collect {|k| Henshin.const_get(k)}
    end
    
    # Need to allow plugins to be sorted by priority
    def <=>(other)
      self.priority <=> other.priority
    end
    
    # Henshin.register! self, :standard_plugin
  end
  
  
  # @deprecated
  class StandardPlugin < Plugin; end
  
  
  
  # @example
  #
  #  class MyMarkupPlugin < Henshin::Generator
  #    def generate(content)
  #      MyMarkup.do_stuff(content)
  #    end
  #    Henshin.register! self, :mymarkup
  #  end
  #
  class Generator < Plugin
    
    # @param [String] content to be rendered
    # @return [String]
    def generate( content )
    end
    
    # Henshin.register! self, :generator
  end
  
  # @example
  #
  #  class MyLayoutPlugin < Henshin::LayoutParser
  #    def generate(content, data)
  #      MyLayout.do_stuff(content).render(data)
  #    end
  #    Henshin.register! self, :mylayout
  #  end
  #
  class LayoutParser < Plugin
    
    # @param [String] content to be rendered
    # @param [Hash] data to be put into the content
    # @return [String]
    def generate( content, data )
    end
    
    # Henshin.register! self, :layout_parser
  end
  
end