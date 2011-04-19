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
    
    # Beware witchcraft. ERB is quite annoying, it won't take a hash
    # but insists on a Binding object, so we give it what it wants. 
    # Pass a hash to +MagicBox#new+ and it creates instance variables
    # for each pair, then call #context on that to get the binding for
    # it. Afterwards though, as highlight appends to @output, remember
    # to collect that variable and return it.
    #
    # @todo Allow recursive calling of variables
    #   For instance, if a hash of {'site' => {'pages' => [x, y, z]}} is
    #   passed and I try to do <%= site.pages.x.url %> it will fail, this
    #   will require traversing the hash and setting up objects for each
    #   key in the hash.
    #
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
