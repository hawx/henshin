require 'yui/compressor'

module Henshin

  class JsCompressor < Compressor
    def initialize(*args)
      super
      @compressor = YUI::JavaScriptCompressor.new
    end

    def compress
      @compressor.compress(super)
    end
  end

end
