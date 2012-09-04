module Henshin

  # Add methods here to make them available in templates.
  module Helpers
    def url_for(path)
      file = @site.all_files.find {|i| i.path === path }
      if file
        file.url
      else
        path
      end
    end
  end

  # Creates an object that can be passed to a template from a Hash of data. Each
  # key becomes a method that returns it's value, this is recursive and works
  # over Arrays.
  #
  # @example
  #
  #   data  = {a: 1, b: 2}
  #   scope = Scope.new(data)
  #
  #   scope.a #=> 1
  #   scope.b #=> 2
  #   scope.c #=> 3
  #
  class Scope

    # @param data [Hash]
    def initialize(data)
      meta = (class << self; self; end)

      data.each do |name, val|
        case val
        when ::Hash
          meta.send(:define_method, name) { Scope.new(val) }
        when ::Array
          meta.send(:define_method, name) {
            val.map {|i|
              i.is_a?(::Hash) ? Scope.new(i) : i
            }
          }
        else
          meta.send(:define_method, name) { val }
        end
      end
    end

    def method_missing(sym, *args)
      nil
    end
  end

end
