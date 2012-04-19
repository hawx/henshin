module Henshin

  # A template file.
  class Template < SlimFile

    def text
      @path.read
    end

    def name
      @path.basename.to_s.split('.').first
    end

  end
end
