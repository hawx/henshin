module Henshin

  class Plugin
   
    # @return [Hash{:input, :output => Array, String}]
    #  the file extensions that can be read by the plugin and the extension
    #  of the output
    #
    # @example
    #  
    #  @extensions = {:input => ['md', 'markdown'],
    #                 :output => 'html'}
    attr_accessor :extensions
    
    # @return [Hash{Symbol => Object}]
    #  the config for the plugin
    attr_accessor :config
    
    # @return [Integer]
    #  The plugins are sorted on priority, high priority plugins are called first.
    #  You could really use any number, but stick to 1 to 5.
    attr_accessor :priority
    
    # Create a new instance of Plugin
    #
    # @param [Site] site that the plugin belongs to
    def initialize(site)
      @extensions = {:input => [],
                     :output => ''}
      @config = {}
      @priority = 3
    end
    
    # Finds all classes that subclass this particular class
    #
    # @return [Array] an array of class objects
    # @see http://www.ruby-forum.com/topic/163430 
    #   modified from the answer given on ruby-forum by black eyes
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
    
    # Plugins are sorted by priority
    def <=>(other)
      self.priority <=> other.priority
    end
    
  end 
  
  # Generator is the plugin type for processing things like markdown
  #
  # @example
  #
  #  class MyMarkupPlugin < Henshin::Generator
  #    def generate(content)
  #      MyMarkup.do_stuff(content)
  #    end
  #  end
  #
  class Generator < Plugin
    
    # This is the method that is called when rendering content
    #
    # @param [String] content to be rendered
    # @return [String]
    def generate( content )
    end

  end
  
  # Layoutor is the plugin type for things like liquid
  #
  # @example
  #
  #  class MyLayoutPlugin < Henshin::Layoutor
  #    def generate(content, data)
  #      MyLayout.do_stuff(content).render(data)
  #    end
  #  end
  #
  class Layoutor < Plugin
    
    # This is the method called when rendering content
    #
    # @param [String] content to be rendered
    # @param [Hash] data to be put into the content
    # @return [String]
    def generate( content, data )
    end
    
  end
  
end