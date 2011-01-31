module Henshin
  # Layouts don't get written directly they are evaluated with a
  # Gen's hash of data.
  class Layout < Henshin::File
  
    def name
      @path.basename.to_s[0...-(@path.extname.size)]
    end
    
    def render_with(file)
      if self.engine
        insert = file.payload
        insert['yield'] = file.content
        self.engine.call(self.content, insert)
      end
    end
    
    def can_write?
      false
    end
    
    def can_render?
      false
    end
    
    def can_layout?
      false
    end
    
  end
end
