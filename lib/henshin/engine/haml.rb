module Henshin::Engine

  autoload_gem :Haml, 'haml'
  
  class Haml
    implement Henshin::Engine
    
    def render(content, data)
      ::Haml::Engine.new(content).render(MagicHash.new(data), {})
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
