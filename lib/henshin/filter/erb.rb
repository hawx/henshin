module Henshin
  module ErbFilter
    include Henshin::Filter
    
    type 'erb'
    patterns '**/*.erb', '**/*.rhtml'
    
    engine do |content, data|
      begin
        ERB.new(content).run(data)
      rescue NameError
        require 'erb'
        retry
      end
    end
  end
end