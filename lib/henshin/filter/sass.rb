require 'henshin/filter'

module Henshin
  module SassFilter
    include Henshin::Filter
    
    type 'sass'
    pattern '**/*.sass'
    
    engine do |content, data|
      begin
        engine = Sass::Engine.new(content, :syntax => :sass)
        engine.render
      rescue NameError
        require 'sass'
        retry
      end
    end
    
    output 'css'
    no_layout true
  end
  
  module ScssFilter
    include Henshin::Filter
    
    type 'scss'
    pattern '**/*.scss'
    
    engine do |content, data|
      begin
        Sass::Engine.new(content, :syntax => :scss).render
      rescue NameError
        require 'sass'
        retry
      end
    end
    
    output 'css'
    no_layout true
  end
end