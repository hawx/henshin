module Henshin

  class SassFile < File
    def text
      SassEngine.render super
    end

    def extension
      '.css'
    end
  end

  File.register '.sass', SassFile

end
