require 'yui/compressor'

module Henshin

  class Compressor
    # Compresses js files using the yui-compressor.
    class Js < Compressor

      def initialize(*args)
        super
        @compressor = YUI::JavaScriptCompressor.new
      end

      # @return [String] The compressed, joined text from the given js files.
      def compress
        @compressor.compress(join)
      end
    end
  end
end
