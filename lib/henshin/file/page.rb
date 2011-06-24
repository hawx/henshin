module Henshin
  class File::Page < File::Text
    set :key,    :page
    set :output, 'html'
  end
end
