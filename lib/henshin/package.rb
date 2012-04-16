module Henshin

  # Concatenates multiple files into one, compressed file.
  class Package < File

    # @param site [Site]
    # @param to [String]
    # @param paths [Array<Pathname>]
    # @param with [Compressor]
    def initialize(site, to, paths, with)
      @site = site
      @compressor = with.new(paths.map {|p| File.create(site, p) })
      @to = to
    end

    # @return [String]
    def text
      @compressor.compress
    end

    # @return [String]
    def extension
      ::File.extname(@to)
    end

    # @return [String]
    def permalink
      "#{@site.url_root}#{@to}"
    end
  end
end
