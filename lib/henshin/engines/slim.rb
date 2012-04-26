require 'slim'

module Henshin

  # Engine which renders slim using the slim gem.
  #
  # @example
  #
  #   SlimEngine.setup
  #   # then later on...
  #   SlimEngine.render "doctype html\n"
  #   #=> "..."
  #
  # @see http://slim-lang.com
  class SlimEngine < Engine

    # Makes an object which responds to the keys in the hash given as method
    # calls.
    #
    # @example
    #
    #   s = ScopeObject.new(name: "John", age: 30)
    #   s.name #=> "John"
    #   s.age  #=> 30
    #   s.job  #=> nil
    #
    class ScopeObject < BasicObject

      # @param data [Hash]
      def initialize(data)
        meta = (class << self; self; end)
        data.each do |k,v|
          case v
          when ::Hash
            meta.send(:define_method, k) { ScopeObject.new(v) }
          when ::Array
            meta.send(:define_method, k) { v.map {|i|
                i.is_a?(Hash) ? ScopeObject.new(i) : i }
            }
          else
            meta.send(:define_method, k) { v }
          end
        end
      end

      def self.const_missing(name)
        ::Object.const_get(name)
      end

      # @return [nil] Any unknown method returns nil.
      def method_missing(sym, *args)
        nil
      end
    end

    def setup(opts={})
      @opts = opts
    end

    def render(text, data={})
      data = ScopeObject.new(data)
      Slim::Template.new(@opts) { text }.render(data) { data.yield }
    end
  end

  Engines.register :slim, SlimEngine

end
