module Henshin

  class File

    module Templatable

      # Overrides #text in the included class so that the result from it is passed
      # into a template. Uses the template set with .template, or if not found, the
      # default template.
      #
      # @return [String]
      def text
        res  = raw_text
        data = clone

        return res if data.template == "none"

        data.singleton_class.send(:define_method, :text) { res }

        default = nil
        singleton_class.ancestors.find {|klass|
          default = klass.default_template if klass.respond_to?(:default_template)
        }

        @site.template(default, Henshin::DEFAULT_TEMPLATE).render(data)
      end
    end
  end
end
