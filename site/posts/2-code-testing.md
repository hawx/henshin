---
title: Code Testing
date:  2012-03-05
---

A test of the code highlighting abilities. This is from henshin past.

``` ruby
require 'henshin/plugin'
require 'liquid'

class LiquidPlugin < Henshin::LayoutParser

  attr_accessor :extensions

  def initialize
    @extensions = []
  end

  def generate( layout, data )
    t = Liquid::Template.parse( read(layout) )
    t.render(data)
  end

  # returns the layout as a string
  def read( file )
    f = File.open(file, "r")
    r = ""
    f.each do |l|
      r << l
    end
    r
  end

end
```
