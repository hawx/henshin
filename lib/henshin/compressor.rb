require 'yui/compressor'

module Henshin

  # Compresses a set of files into one big ol' ugly file.
  class Compressor

    def initialize(files=[])
      @files = files
    end

    def compress
      @files.map {|f| f.text }.join("\n")
    end
  end

  # TODO: actually use some form of minifier.
  class CssCompressor < Compressor
    def initialize(*args)
      super
      @compressor = YUI::CssCompressor.new
    end

    def compress
      @compressor.compress(super)
    end
  end

  # TODO: actually use some form of minifier.
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
