module Henshin::Engine::Support
  
  # Wrapper for pygments
  #
  # @example
  #
  #   code = <<EOS
  #   def my_method(arg)
  #     p arg
  #   end
  #   EOS
  #
  #   Henshin::Pygments.highlight code, :ruby
  #   #=> (some marked up html)
  #
  class Pygments
  
    def self.highlight(*args)
      new(*args).highlight
    end
    
    attr_reader :code, :lang
    
    # @param code [String]
    #   Code to be highlighted.
    #
    # @param lang [Symbol, String]
    #   Name of language code is in, see http://pygments.org/languages/
    #   or run `pygmentize -L` for names to use. Use lower case names, 
    #   eg. Objective-C should be passed as 'objective-c', Ruby as 
    #   'ruby' (or :ruby) and so on.
    #
    def initialize(code, lang)
      @code = code
      @lang = lang
    end
    
    def highlight
      command = "pygmentize -f html -O nowrap=true -l #{@lang}"
      IO.popen(command, mod = 'r+') do |pyg|
        pyg << @code
        pyg.close_write
        pyg.read.strip
      end
    end
    
    def self.available?
      r = `which pygmentize`
      if r[0] == "/"
        true
      else
        false
      end
    end
  
  end
  
end
