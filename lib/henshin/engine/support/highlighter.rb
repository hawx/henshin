%w(pygments uv coderay syntax highlight_scanner).each do |l|
  require_relative l
end

module Henshin::Engine::Support
  class Highlighter
  
    LIBRARIES = {
      :coderay  => CodeRay,
      :pygments => Pygments,
      :syntax   => Syntax,
      :uv       => Uv      
    }
    
    def self.highlight(*args)
      new.highlight(*args)
    end
  
    def highlight(code, lang, prefs=[:pygments, :uv, :syntax, :coderay])
      unless @highlighter
        @highlighter = prefs.map {|k| LIBRARIES[k]}.find {|l| l.available? }
      end
      
      "<pre class=\"highlight #{lang}\"><code>" + @highlighter.highlight(code, lang) + "</code></pre>"
    end

  end
end
