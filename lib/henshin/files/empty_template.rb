module Henshin

  class EmptyTemplate < AbstractFile

    def initialize
      # ...
    end

    def text
      ""
    end

    def name
      "none"
    end

    def template(*args)
      ""
    end

  end
end
