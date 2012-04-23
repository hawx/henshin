module Henshin

  # @abstract Must implement {#permalink}.
  # Concatenates multiple files into one, compressed file.
  class Package
    include FileInterface

    # @param site [Site]
    # @param to [String]
    # @param paths [Array<Pathname>]
    # @param with [Compressor]
    def initialize(site, compressor)
      @site = site
      @compressor = compressor
    end

    # @return [String]
    def text
      @compressor.compress
    end

    # @return [String]
    def permalink
      # ...
    end
  end
end
