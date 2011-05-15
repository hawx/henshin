require 'henshin/engine/support/highlighter'

module Henshin::Engine
  
  autoload_gem :ERB, 'erb'
  
  class ERB
    implement Henshin::Engine
    
    def render(content, data)
      box = MagicBox.new(data)
      ::ERB.new(content, nil, nil, "@output").run(box.context)
      box.output
    end
    
    class MagicBox < MagicHash
      attr_reader :output
    
      def context
        binding
      end
      
      # Adds highlighting block for code.
      #
      # @example
      #
      #   <% highlight :ruby do %>
      #   def method(arg)
      #     p arg
      #   end
      #   <% end %>
      #
      # Jay Fields to thank for the @output appending:
      # http://blog.jayfields.com/2007/01/appending-to-erb-output-from-block.html
      #
      def highlight(lang)
        pre = @output.dup
        post = yield
        code = post[pre.size..-1]
        res = Support::Highlighter.highlight(code, lang)

        @output = pre + res
        
      end
    end
    
  end
end

Henshin.register_engine :erb, Henshin::Engine::ERB
