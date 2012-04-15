module Henshin

  class StylePackage < Package
    def initialize(site, paths)
      super(site, 'style.css', paths, CssCompressor)
    end
  end
end
