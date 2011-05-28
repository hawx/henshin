class Henshin::Engine

  autoload_gem :Nokogiri, 'nokogiri'
  
  class Nokogiri < Henshin::Engine
    register :nokogiri
    
    def render(content, data)
      builder = ::Nokogiri::XML::Builder.new
      builder.context = MagicHash.new(data)
      builder.instance_eval(content)
      builder.to_xml.gsub(/^<\?xml version=\"1\.0\"\?>\n?/, "")
    end
  end
end
