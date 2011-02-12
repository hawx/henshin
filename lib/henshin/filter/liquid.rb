module Henshin
  module LiquidFilter
    include Henshin::Filter
    
    type 'liquid'
    patterns '**/*.liquid', '*.liquid'
    
    engine do |content, data|
      begin
        Liquid::Template.parse(content).render(data)
      rescue NameError
        require 'liquid'
        Liquid::Template.parse(content).render(data)
      end
    end
    
  end
  
end
