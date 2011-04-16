module Henshin::Engine::Support

  autoload_gem :Syntax, 'syntax/convertors/html'
  
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
      ::Syntax::Convertors::HTML.for_syntax(@lang.to_s).convert(@code)[5..-7]
    end
    
    def self.available?
      require 'syntax'
      true
    rescue LoadError
      false
    end

  end
end
