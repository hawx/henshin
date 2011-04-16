---
title: Testing Out That Code
date: 11:04 14/12/2010
layout: post
tag: codes
---

Okay here goes...

$highlight ruby
module Henshin
  
  autoload_gem :Maruku, 'maruku'
  
  class Maruku
    implements Engine
    
    def render(content, data)
      content = Henshin::HighlightScanner.highlight(content)
      ::Maruku.new(content).to_html
    end
  end
  
end

$end