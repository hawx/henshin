module Henshin

  # Allows Sinatra style route matching.
  #
  # +:keys+: match any words and are returned by #matches within the hash with
  # the name of the key given.
  #
  # +*+: wildcard matches any words and is returned by #matches in the +splat+
  # array.
  #
  # +**+: recursive wildcard __optionally__ matches multiple directories.
  #
  # +{a,b,c}+: matches any of the items given, only.
  #
  # @example
  #
  #   m = Matcher.new('/{site,blog}/**/:title.:ext')
  #   m.matches? '/a/b/c.d'         #=> false
  #   m.matches? '/site/index.html' #=> true
  #   m.matches '/blog/post/coding/matchers.md'
  #   #=> {
  #   #     "group" => "blog"
  #   #     "splat" => ["post/condig/"],
  #   #     "title" => "matchers",
  #   #     "ext"   => "md"
  #   #   }
  #
  # @see https://github.com/sinatra/sinatra/blob/1632f24b7d15e846d676dfd93d2cfeeafbaf03fb/lib/sinatra/base.rb#L738
  #   Which this is heavily based on
  #
  class Matcher
  
    attr_accessor :keys
    
    def initialize(match)
      @pretty = match.to_s
      if match.is_a? Matcher
        @match = match.regex
        @keys = match.keys
      elsif match.is_a? Regexp
        @match = match
        @keys = []
      else
        keys = []
        special_chars = %w{. + ( ) $}
        pattern = match.to_str.gsub(/((:\w+)|\*\*\/?|\{(\w+,?)*\}|[\*#{special_chars.join}])/) do |match|
            case match
            when /\{(\w+,?)*\}/
              items = match[1..-2].split(',')
              keys << 'group'
              "(#{items.join('|')})"
            when '**/' # make the top directory optional!
              keys << 'splat'
              "(.+\/)?"
            when '**'
              keys << 'splat'
              "(.+)?"
            when "*"
              keys << 'splat'
              "([^/?#]+)?"
            when *special_chars
              Regexp.escape(match)
            else
              if $2
                keys << $2[1..-1]
              else
                keys << match[1..-1]
              end
              "([^/?#]+)"
            end
          end
        @match = /^#{pattern}$/
        @keys = keys
      end
    end
    
    def matches?(other)
      if @match.match(other)
        true
      else
        false
      end
    end
    
    # @return [Hash]
    #   Has the key 'splat' defined as an array of any * or ** matches, then
    #   for every named key the name given has the value of the match.
    #
    def matches(other)
      if match = @match.match(other)
        values = match.captures.to_a
        params = 
          if @keys.any?
            @keys.zip(values).inject({}) do |hash, (k,v)|
              if k == 'splat'
                (hash[k] ||= []) << v
              else
                hash[k] = v
              end
              hash
            end
          elsif values.any?
            {'captures' => values}
          else
            {}
          end
      else
        false
      end
    end
    
    def regex
      @match
    end
    
    def to_s
      @pretty
    end
    
    def inspect
      "#<Henshin::Matcher \"#{@pretty}\">"
    end
    
  end
end