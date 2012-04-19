require 'yui/compressor'

module Henshin

  # Compresses css files using the yui-compressor.
  class CssCompressor < Compressor

    def initialize(*args)
      super
      @compressor = YUI::CssCompressor.new
    end

    # @return [String] The compressed, joined text from the given css files.
    def compress
      @compressor.compress(super)
    end
  end

end
