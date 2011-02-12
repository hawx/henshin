module Henshin
  # Allows Sinatra style route matching
  class Matcher
  
    def initialize(match)
      if match.is_a? Regexp
        @match = match
        @keys = []
      else
        keys = []
        special_chars = %w{. + ( ) $}
        pattern = 
          match.to_str.gsub(/((:\w+)|\*\*|[\*#{special_chars.join}])/) do |match|
            case match
            when '**'
              keys << 'splat'
              "(.+)?"
            when "*"
              keys << 'splat'
              "([^/?#]+)?"
            when *special_chars
              Regexp.escape(match)
            else
              keys << $2[1..-1]
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
  end
end