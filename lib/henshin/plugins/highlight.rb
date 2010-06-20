require 'henshin/plugin'
require 'simplabs/highlight'

class HighlightPlugin < Henshin::Generator
  
  attr_accessor :priority, :config, :extensions
  
  def initialize
    @extensions = {:input => ['*']}
    @config = {}
    @priority = 1
  end
  
  def configure( override )
    @config.merge!(override) if override
  end
  
  def generate( content )
    content =~ /(\$highlight)\s+(.+)((\n.*)+)(\$end)/
    if $1
      lang = $2.to_sym
      code = $3[1..-1] # removes first new line
      insert = '<pre><code>' + Simplabs::Highlight.highlight(lang, code) + '</code></pre>'
      content.gsub(/(\$highlight.*\$end)/m, insert)
    else
      content
    end
  end
  
  Henshin.register! self
end