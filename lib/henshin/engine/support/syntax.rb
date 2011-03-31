module Henshin::Engine::Support

  autoload_gem :Syntax, 'syntax'
  
  # @see Henshin::Pygments
  class Syntax

    def self.highlight(*args)
      new(*args).highlight
    end
    
    attr_reader :code, :lang
    
    def initialize(code, lang)
      @code = code
      @lang = lang
    end
    
    def highlight
      Syntax::Convertors::HTML.for_syntax(@lang).convert(@code)
    end
    
    def self.available?
      require 'syntax'
      true
    rescue LoadError
      false
    end

  end
end
