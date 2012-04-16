module Henshin

  # Concatenates script files (java/coffee-script) then minifies them.
  class ScriptPackage < Package

    # @param site [Site]
    # @param paths [Array<Pathname>]
    def initialize(site, paths)
      super(site, 'script.js', paths, JsCompressor)
    end
  end
end
