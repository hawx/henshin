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

end
