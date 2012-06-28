module Henshin

  # Uses {SassEngine} to render text.
  class SassFile < File

    # @return [String] Css compiled from the sass source.
    def text
      Tilt[:sass].new(nil, nil, @site.config[:sass]) { super }.render
    end
  end

  File.register /\.sass/, SassFile

end
