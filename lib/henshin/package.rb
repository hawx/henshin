module Henshin

  # @abstract Must implement {#path}.
  # Concatenates multiple files into one, compressed file.
  class Package < AbstractFile

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

    def path
      # Path site, '...'
    end
  end
end
