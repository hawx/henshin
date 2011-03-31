module Henshin::Engine

  autoload_gem :RedCloth, 'redcloth'
  
  class RedCloth
    implement Henshin::Engine
    
    def render(content, data)
      # content = Henshin::HighlightScanner.highlight(content)
      r = ::RedCloth.new(content)
      r.extend(HighlightTag)
      r.to_html
    end
    
    module HighlightTag
    
      # Adds highlighting keyword for redcloth. Beware it does not like
      # empty lines in the middle of your code.
      #
      # @example
      #
      #   h1. Some Code
      #
      #   highlight. ruby
      #   def method(arg)
      #     p arg
      #   end
      #
      #   And back to a paragraph
      #
      def highlight(t)
        type = t[:type]
        text = t[:text].gsub('<br />', '')
        lang = text.split("\n")[0]
        code = text.split("\n")[1..-1].join("\n")
        
        Support::Highlighter.highlight(code, lang)
      end
    end
    
    
  end
  
end
