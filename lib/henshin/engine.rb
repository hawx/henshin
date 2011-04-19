require 'interface'

module Henshin

  # @example Definition
  #
  #   # Note: Module#autoload won't load gems so use this.
  #   autoload_gem :Maruku, 'maruku'
  #
  #   class Maruku
  #     implements Engine
  #
  #     def render(content, data)
  #       ::Maruku.new(content).to_html
  #     end
  #   end
  #
  # @example Use
  #
  #   render '**/*.md' do
  #     apply Maruku
  #   end
  #
  module Engine
  
    # renders the content using the data
    def render(content, data)
    end
    
    # Make .render go to #render
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    module ClassMethods
      def render(*args)
        (@instance ||= new).render(*args)
      end
    end
    
    # This is useful for some types of engines, if it uses the data eg. ERB
    # then this will be needed. It takes a hash (can be nested) and sets
    # each key-vale pair as an instance variable on the class. It recursively
    # creates MagicHash instances if a hash value is found. It then implements
    # #method_missing to allow the instance variable to be accessed without the @
    #
    class MagicHash
      def initialize(hash)
        hash.each do |k, v|
          if v.is_a?(Hash)
            instance_variable_set("@#{k}", MagicHash.new(v))
          else
            instance_variable_set("@#{k}", v)
          end
        end
      end
      
      def [](key)
        instance_variable_get("@#{key}")
      end
      
      def method_missing(sym, *args, &block)
        if ivar = self[sym]
          ivar
        else
          super
        end
      end
    end
    
  end
  
end