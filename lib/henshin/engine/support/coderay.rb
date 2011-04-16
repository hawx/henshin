module Henshin::Engine::Support

  autoload_gem :CodeRay, 'coderay'
  
  class CodeRay
  
    def self.highlight(*args)
      new(*args).highlight
    end
    
    attr_reader :code, :lang
    
    def initialize(code, lang)
      @code = code
      @lang = lang
    end
    
    def highlight
      tokens = ::CodeRay.scan(code, lang)
      tokens.div(:css => :class)[47..-21]
    end
    
    def self.available?
      require 'coderay'
      true
    rescue LoadError
      false
    end
  
  end

end