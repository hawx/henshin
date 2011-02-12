module Henshin
  module HamlFilter
    include Henshin::Filter
    
    type 'haml'
    pattern '**/*.haml'
    
    engine do |content, data|
      begin
        Haml::Engine.new(content).render(Object.new, data)
      rescue NameError
        require 'haml'
        retry
      end
    end
  end
end