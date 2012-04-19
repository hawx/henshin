require 'yui/compressor'

module Henshin

  # Compresses js files using the yui-compressor.
  class JsCompressor < Compressor

    def initialize(*args)
      super
      @compressor = YUI::JavaScriptCompressor.new
    end

    # @return [String] The compressed, joined text from the given js files.
    def compress
      @compressor.compress(super)
    end
  end

end
