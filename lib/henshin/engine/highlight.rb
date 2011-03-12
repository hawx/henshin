module Henshin

  autoload_gem :Simplabs, 'simplabs/highlight'
  
  class Highlight
    implements Engine
    
    REGEX = /(\$highlight)\s+(.+)((\n.*)+)(\$end)/
    
    # Would probably be nicer to match different styles for each file type,
    # so the syntax doesn't look so alien.
    REGEXES = {
      :default => //,
      :maruku => //,
      :liquid => //
    }
    
    def render(content, data)
      content =~ REGEX
      if $1
        lang = $2.to_sym
        code = $3[1..-1]
        insert = "<pre class=\"highlight\"><code>" + Simplabs::Highlight.highlight(lang, code) + "</code></pre>"
        content.gsub(/(\$highlight.*\$end)/m, insert)
      else
        content
      end
    end
  end

end