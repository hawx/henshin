require 'henshin/filter'

module Henshin
  module RedClothFilter
    include Henshin::Filter
    
    type 'textile'
    pattern '**/*.textile'
    
    engine do |content, data|
      begin 
        RedCloth.new(content).to_html
      rescue NameError
        require 'redcloth'
        retry
      rescue LoadError
        warn "You do not have the redcloth gem installed\nuse 'gem install RedCloth'"
      end
    end
  end
end