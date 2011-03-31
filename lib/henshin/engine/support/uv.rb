module Henshin::Engine::Support

  autoload_gem :Uv, 'uv'
  
  # @see Henshin::Pygments
  class Uv

    def self.highlight(*args)
      new(*args).highlight
    end
    
    attr_reader :code, :lang
    
    def initialize(code, lang)
      @code = code
      @lang = lang
    end
    
    def highlight
      ::Uv.parse(@code, "xhtml", @lang, false, "amy")
    end
    
    def self.available?
      require 'uv'
      true
    rescue LoadError
      false
    end

  end
end
