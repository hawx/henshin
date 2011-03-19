module Henshin
  
  autoload_gem :ERB, 'erb'
  
  class ERB
    implements Engine
    
    def render(content, data)
      box = MagicBox.new(data).context
      ::ERB.new(content, nil, nil, "@output").run(box)
      eval("@output", box)
    end
    
    # Beware witchcraft. ERB is quite annoying, it won't take a hash
    # but insists on a Binding object, so we give it what it wants. 
    # Pass a hash to +MagicBox#new+ and it creates instance variables
    # for each pair, then call #context on that to get the binding for
    # it. Afterwards though, as highlight appends to @output, remember
    # to collect that variable and return it.
    class MagicBox
      def initialize(hash)
        hash.each do |k, v|
          instance_variable_set("@#{k}", v)
        end
      end
      
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
        @output << Henshin::Highlighter.highlight(yield, lang)
      end
    end
  end
  
end
