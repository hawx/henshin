module Henshin::Engine

  autoload_gem :Builder, 'builder'
  
  class Builder
    implement Henshin::Engine
    
    def render(content, data)
      xml = ::Builder::XmlMarkup.new(:indent => 2)
      xml.instance_eval(content)
      xml.target!
    end
  end

end