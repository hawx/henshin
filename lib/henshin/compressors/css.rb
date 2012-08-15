require 'yui/compressor'

module Henshin

  class Compressor
    # Compresses css files using the yui-compressor.
    class Css < Compressor

      def initialize(*args)
        super
        @compressor = YUI::CssCompressor.new
      end

      # @return [String] The compressed, joined text from the given css files.
      def compress
        @compressor.compress(join)
      end
    end
  end
end
