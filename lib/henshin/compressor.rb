module Henshin

  # @abstract You need to implement {#compress}.
  #
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

    # @return [String] Simply joins the contents of all +files+ into a single
    #   string separated by newlines.
    def join
      @files.map {|file| file.text }.join("\n")
    end

    # @return [String] The compressed text for the +files+.
    def compress
      join
    end
  end

end
