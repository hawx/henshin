require 'henshin/engine/support/highlighter'

class Henshin::Engine

  autoload_gem :Haml, 'haml'
  
  class Haml < Henshin::Engine
    register :haml
    
    def render(content, data)
      ::Haml::Engine.new(content).render(MagicHash.new(data), {}) { data['yield'] }
    end
    
    # Adds a highlight filter to haml.
    #
    # @example
    #
    #   %p
    #     Some paragraph
    #
    #   :highlight
    #     $ruby
    #
    #     def method(arg)
    #       p arg
    #     end
    #
    module Highlight
      include ::Haml::Filters::Base
      
      def render(text)
        lines = text.split("\n")
        lang = lines[0][1..-1]
        code = lines[1..-1].join("\n")
        Support::Highlighter.highlight(code, lang)
      end
    end
    
  end
end
