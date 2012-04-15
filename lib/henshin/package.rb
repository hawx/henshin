module Henshin

  class Package < File
    def initialize(site, to, paths, with)
      @site = site
      @compressor = with.new(paths.map {|p| File.create(site, p) })
      @to = to
    end

    def text
      @compressor.compress
    end

    def extension
      ::File.extname(@to)
    end

    def permalink
      "#{@site.url_root}#{@to}"
    end
  end
end
