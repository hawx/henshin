module Henshin

  class StylePackage < Package

    def initialize(site, paths)
      compressor = CssCompressor.new(paths.map {|p| File.create(site, p) })
      super(site, compressor)
    end

    def enabled?
      @site.config[:compress][:styles]
    end

    def path
      Path @site.root, 'style.css'
    end
  end
end
