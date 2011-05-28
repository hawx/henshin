module Henshin

  # Layouts don't get written directly they are evaluated with a
  # File's hash of data.
  class Layout < Henshin::File
  
    def name
      @path.basename.to_s[0...-(@path.extname.size)]
    end
    
    def render_with(file)
      r = ""
      insert = file.payload
      insert['yield'] = file.content
    
      if @applies
        @applies.each do |engine|
          r = engine.render(self.content, insert)
        end
      end
      
      r
    end
    
    set :write,  false
    set :render, false
    set :layout, false
    
  end
end
