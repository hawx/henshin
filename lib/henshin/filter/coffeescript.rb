require 'henshin/filter'

module Henshin
  module CoffeeScriptFilter
    include Henshin::Filter
    
    type 'coffeescript'
    pattern '**/*.coffee'
    
    engine do |content, data|
      begin
        CoffeeScript.compile(content)
      rescue NameError
        require 'coffee-script'
        retry
      end
    end
    
    output 'js'
  end
end