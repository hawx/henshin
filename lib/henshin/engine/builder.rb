class Henshin::Engine

  autoload_gem :Builder, 'builder'
  
  class Builder < Henshin::Engine
    register :builder
    
    def render(content, data)
      xml = ::Builder::XmlMarkup.new(:indent => 2)
      xml.instance_eval(content)
      xml.target!
    end
  end
end
