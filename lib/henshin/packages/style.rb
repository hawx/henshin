module Henshin

  class StylePackage < Package

    def initialize(site, paths)
      compressor = CssCompressor.new(paths.map {|p| File.create(site, p) })
      super(site, compressor)
    end

    def path
      Path @site, '/style.css'
    end
  end
end
