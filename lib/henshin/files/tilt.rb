module Henshin

  class File

    class Tilt < File

      EXTENSIONS = %w(str
                      sass scss less
                      coffee
                      markdown mkd md
                      textile
                      rdoc
                      wiki creaole
                      mediawiki mw).map(&:to_sym)

      def text
        ext    = @path.extname[1..-1].to_sym
        config = (@site.config[ext] || {}).to_hash.symbolise
        ::Tilt[ext].new(nil, nil, config) { super }.render
      end

    end

    class TiltTemplate < File

      EXTENSIONS = %w(erb rhtml erubis
                      haml
                      nokogiri
                      builder
                      mab
                      liquid
                      radius
                      slim
                      yajl).map(&:to_sym)

      def data
        self
      end

      def text
        ext = @path.extname[1..-1].to_sym
        scope = data

        text = ::Tilt[ext].new(nil, nil, (@site.config[ext] || {}).to_hash.symbolise) {
          super
        }.render(scope) { scope.yield }

        return text if scope.template == 'none'

        default = nil
        singleton_class.ancestors.find {|klass|
          default = klass.default_template if klass.respond_to?(:default_template)
        }

        templates = [scope.template, default, Henshin::DEFAULT_TEMPLATE].compact

        @site.template(*templates).render(data)
      end

    end

    register /\.(#{Tilt::EXTENSIONS.join('|')})\Z/, Tilt
    register /\.(#{TiltTemplate::EXTENSIONS.join('|')})\Z/, TiltTemplate

  end
end
