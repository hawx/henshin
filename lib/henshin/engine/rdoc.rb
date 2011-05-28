require 'henshin/engine/support/highlighter'

class Henshin::Engine

  autoload_gem :RDoc, 'rdoc/markup'
  autoload_gem :RDoc, 'rdoc/markup/to_html'
  
  class RDoc < Henshin::Engine
    register :rdoc
    
    def render(content, data)
      markup = ::RDoc::Markup::ToHtml.new
      markup.convert(content)
      markup.res.join("")
    end
  
  end 
end

