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

  end

  # TODO: actually use some form of minifier.
  class JsCompressor < Compressor

  end

end