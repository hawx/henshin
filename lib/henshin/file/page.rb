module Henshin
  class Page < Henshin::File
    def initialize(*args)
      @key = :page
      @output = 'html'
      super
    end
  end
end