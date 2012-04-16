module Henshin

  # Compresses a set of files into one big ol' ugly file.
  class Compressor

    # @param files [Array<File>]
    def initialize(files=[])
      @files = files
    end

    # @return [String]
    def compress
      @files.map {|f| f.text }.join("\n")
    end
  end

end
