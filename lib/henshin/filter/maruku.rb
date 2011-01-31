require 'henshin/filter'

module Henshin
  module MarukuFilter
    include Henshin::Filter
    
    type 'markdown'
    patterns '**/*.md', '**/*.markdown', '**/*.mkd'
    
    engine do |content, data|
      begin
        doc = Maruku.new(content)
        doc.to_html
      rescue NameError
        require 'maruku'
        retry
      end
    end
  end
end