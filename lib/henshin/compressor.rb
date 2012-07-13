module Henshin

  # Compresses a set of files into one big ol' ugly file.
  #
  # @example
  #
  #   compressed = Compressor.new(files)
  #   compressed.compress #=> "..."
  #
  class Compressor

    # @param files [Array<File>]
    def initialize(files=[])
      @files = files
    end

    def join
      @files.map {|f| f.text }.join("\n")
    end

    # @return [String] The text of the given files joined together.
    def compress
      join
    end
  end

end
