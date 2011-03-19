require_relative 'pygments'
require_relative 'ultraviolet'
require_relative 'highlight_scanner'

module Henshin
  class Highlighter
  
    LIBRARIES = {
      :pygments    => Pygments,
      :uv          => UltraViolet,
      :ultraviolet => UltraViolet
    }
    
    def self.highlight(*args)
      new.highlight(*args)
    end
  
    def highlight(code, lang, prefs=[:pygments, :uv])
      unless @highlighter
        @highlighter = prefs.map {|k| LIBRARIES[k]}.find {|l| l.available? }
      end
      
      @highlighter.highlight(code, lang)
    end

  end
end
