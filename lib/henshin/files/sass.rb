module Henshin

  # Uses {SassEngine} to render text.
  class SassFile < File

    # @return [String] Css compiled from the sass source.
    def text
      Engines.render :sass, super
    end

    def extension
      '.css'
    end
  end

  File.register /\.sass/, SassFile

end
