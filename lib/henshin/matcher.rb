module Henshin
  # Allows Sinatra style route matching
  class Matcher
  
    attr_accessor :keys
  
    # Most of this was ripped straight out of sinatra, remember to credit it!
    puts 'Alert do not release, lib/henshin/matcher.rb:6'
    
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