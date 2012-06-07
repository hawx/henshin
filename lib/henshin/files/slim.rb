require 'slim'

module Henshin

  # Uses the {SlimEngine} to render text.
  class SlimFile < File

    class Scope
      def initialize(hash)
        meta = (class << self; self; end)

        hash.each do |name, val|
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

    # Renders the slim source with the file's data. Applies a template to the
    # result unless the yaml contains +template: none+.
    #
    # @return [String] Html compiled from the slim source and data.
    def text
      scope = Scope.new(@site.data.merge(data))
      text  = Slim::Template.new(nil, nil, @site.config[:slim]) { super }.render(scope) { scope.yield }

      return text if data[:template] == 'none'

      @site.template(data[:template], data.merge(yield: text))
    end

    def path
      Path @site.url_root, super.to_s.sub(/\.slim$/, '.html')
    end
  end

  File.register /\.slim/, SlimFile

end
