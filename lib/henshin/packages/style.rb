module Henshin

  class Package
    class Style < Package

      def initialize(site, paths)
        compressor = Compressor::Css.new(paths.map {|p| File.create(site, p) })
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
end
