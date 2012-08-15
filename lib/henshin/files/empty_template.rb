module Henshin

  class File
    class EmptyTemplate < Abstract

      def initialize
        # ...
      end

      def text
        ""
      end

      def name
        "none"
      end

      def render(*args)
        ""
      end

    end
  end
end
