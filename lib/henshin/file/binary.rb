module Henshin

  class File::Binary < File
    
    set :read,   true
    set :render, false
    set :layout, false
    set :write,  true
  
  end
end