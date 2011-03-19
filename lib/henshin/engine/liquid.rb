module Henshin

  autoload_gem :Liquid, 'liquid'
  
  class Liquid
    implements Engine
    
    def render(content, data)
      ::Liquid::Template.parse(content).render(data)
    end
    
    # Adds code highlighting tag block.
    #
    # @example
    #
    #   {% highlight ruby %}
    #   def method(arg)
    #     p arg
    #   end
    #   {% endhighlight %}
    #
    class Highlight < ::Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        m = markup.match(/(\w+)\s*/)
        @lang = m[1]
      end
      
      def render(context)
        Henshin::Highlighter.highlight(super[0], @lang)
      end
    end
    
    ::Liquid::Template.register_tag('highlight', Henshin::Liquid::Highlight)
  end
  
end
