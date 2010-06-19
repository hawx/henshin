require 'henshin/plugin'
require 'simplabs/highlight'

class HighlightPlugin < Henshin::Generator
  
  def initialize
    @extensions = {:input => ['markdown'],
                   :output => ''}
    @config = {}
  end
  
  def configure( override )
    @config.merge!(override) if override
  end
  
  def generate( content )
    content =~ /(\$highlight)\s+(.+)((\n.*)+)(\$end)/
    if $1
      lang = $2.to_sym
      code = $3[1..-1] # removes first new line
      '<pre><code>' + Simplabs::Highlight.highlight(lang, code) + '</code></pre>'
    end
  end
  
  Henshin.register! self
end