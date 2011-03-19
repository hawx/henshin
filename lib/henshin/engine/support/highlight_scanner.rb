module Henshin

  autoload_gem :StringScanner, 'strscan'
  
  class HighlightScanner
    
    OPEN  = /\$\s*highlight/
    LANG  = /(\w+)/
    CLOSE = /\$\s*end(highlight)?/
  
    def self.highlight(*args)
      new(*args).highlight
    end
    
    attr_reader :text
    
    def initialize(text)
      @text = text
    end
    
    def highlight
      @scanner = StringScanner.new(@text)
      r = ""
      until @scanner.eos?
        a = scan_code || a = scan_text
        r << a
      end
      
      r
    end
    
    private
    
    def scan_code
      return unless @scanner.scan(OPEN)
      @scanner.scan(/\s*/)         # remove spaces
      lang = @scanner.scan(/\w+$/) # get the language name
      @scanner.scan(/\n/)          # remove the newline
      code = scan_until(CLOSE)  # match before '$end'
      @scanner.scan(CLOSE)         # remove the '$end' bit
      
      "<pre class=\"highlight #{lang}\"><code>" + Henshin::Highlighter.highlight(code, lang) + "</code></pre>"
    end
    
    def scan_text
      text = scan_until(OPEN)
      
      if text.nil?
        text = @scanner.rest
        @scanner.clear
      end
      
      text
    end
    
    def scan_until(reg)
      pos = @scanner.pos
      if @scanner.scan_until(reg)
        @scanner.pos -= @scanner.matched.size
        @scanner.pre_match[pos..-1]
      end
    end
  end
end
