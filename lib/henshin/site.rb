module Henshin

  class Site

    attr_reader :root

    def initialize(root='.')
      @root = Pathname.new(root)
    end

  end
end
