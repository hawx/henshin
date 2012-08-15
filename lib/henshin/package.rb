module Henshin

  # @abstract Must implement {#path}.
  # Concatenates multiple files into one, compressed file.
  class Package < File::Abstract

    # @param site [Site]
    # @param to [String]
    # @param paths [Array<Pathname>]
    # @param with [Compressor]
    def initialize(site, compressor)
      @site = site
      @compressor = compressor
    end

    def enabled?
      true
    end

    # @return [String]
    def text
      enabled? ? @compressor.compress : @compressor.join
    end

    def path
      # Path site, '...'
    end
  end
end
