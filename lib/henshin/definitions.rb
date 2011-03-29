require 'interface'

module Henshin

  # Include this in a module so that it can be included in a subclass of Henshin::Base
  # to populate with predefined #render calls. Define them in exactly the same way.
  #
  # @example
  #
  #   module LiquidRender
  #     include RenderDefinition
  #
  #     render '**/:title.liquid' do
  #       apply LiquidEngine
  #       set :title, keys[:title]
  #     end
  #   end
  #
  # @todo Give this a better name
  #   
  module RenderDefinition
  
    def self.included(mod)
      mod.extend(ClassMethods)
      mod.instance_variable_set("@_render", [])
    end
    
    module ClassMethods
      def render(path, &block)
        @_render << [path, block]
      end
      
      def included(klass)
        # set the renders
        @_render.each do |(path, block)|
          klass.render(path, &block)
        end
      end
    end
  
  end
  
end