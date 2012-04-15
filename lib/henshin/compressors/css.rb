require 'yui/compressor'

module Henshin

  class CssCompressor < Compressor
    def initialize(*args)
      super
      @compressor = YUI::CssCompressor.new
    end

    def compress
      @compressor.compress(super)
    end
  end

end
