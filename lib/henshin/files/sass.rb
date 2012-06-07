module Henshin

  # Uses {SassEngine} to render text.
  class SassFile < File

    # @return [String] Css compiled from the sass source.
    def text
      Tilt::SassTemplate.new(nil, nil, @site.config[:sass]) { super }.render
    end

    def extension
      '.css'
    end
  end

  File.register /\.sass/, SassFile

end
