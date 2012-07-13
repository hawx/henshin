module Henshin

  # Concatenates script files (java/coffee-script) then minifies them.
  class ScriptPackage < Package

    # @param site [Site]
    # @param paths [Array<Pathname>]
    def initialize(site, paths)
      compressor = JsCompressor.new(paths.map {|p| File.create(site, p) })
      super(site, compressor)
    end

    def enabled?
      @site.config[:compress][:scripts]
    end

    def path
      Path @site.url_root, 'script.js'
    end
  end
end
