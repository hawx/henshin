module Henshin

  class ScriptPackage < Package
    def initialize(site, paths)
      super(site, 'script.js', paths, JsCompressor)
    end
  end
end
