module Henshin

  class Package
    # Concatenates script files (java/coffee-script) then minifies them.
    class Script < Package

      # @param site [Site]
      # @param paths [Array<Pathname>]
      def initialize(site, paths)
        compressor = Compressor::Js.new(paths.map {|p| File.create(site, p) })
        super(site, compressor)
      end

      def enabled?
        @site.config[:compress][:scripts]
      end

      def path
        Path @site.root, 'script.js'
      end
    end
  end
end
