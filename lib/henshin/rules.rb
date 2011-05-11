module Henshin

  # Include this in a module so that it can be included in a subclass of Henshin::Base
  # to populate with predefined #rule calls. Define them in exactly the same way.
  #
  # @example
  #
  #   module LiquidRender
  #     extend Rules
  #
  #     rule '**/:title.liquid' do
  #       apply LiquidEngine
  #       set :title, keys[:title]
  #     end
  #   end
  #   
  module Rules
  
    def self.extended(mod)
      mod.instance_variable_set("@_rule", [])
    end
    
    def rule(path, &block)
      @_rule << [path, block]
    end
    
    def included(klass)
      # set the rules
      @_rule.each do |(path, block)|
        klass.rule(path, &block)
      end
    end
  
  end
  
end