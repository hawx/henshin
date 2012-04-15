require 'slim'

module Henshin

  # Engine which renders slim using the slim gem.
  # @see http://slim-lang.com
  class SlimEngine < Engine

    class ScopeObject
      def initialize(data)
        meta = (class << self; self; end)
        data.each do |k,v|
          case v
          when Hash
            meta.send(:define_method, k) { ScopeObject.new(v) }
          when Array
            meta.send(:define_method, k) { v.map {|i| ScopeObject.new(i) } }
          else
            meta.send(:define_method, k) { v }
          end
        end
      end

      def method_missing(sym, *args)
        nil
      end
    end

    def self.setup(opts={})
      @opts = opts
    end

    def self.render(text, data={})
      data = ScopeObject.new(data)
      Slim::Template.new(@opts) { text }.render(data) { data.yield }
    end
  end
end
