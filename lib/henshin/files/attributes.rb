require 'set'

module Henshin

  class File

    # Extend any module (classes will generally be inheriting from {AbstractFile}
    # so will pick this up) with this module to gain the ability to set required
    # yaml keys and default templates.
    module Attributes

      def requires(*keys)
        @required ||= Set.new
        @required  += keys
      end

      def required
        @required || Set.new
      end

      def template(name)
        @template = name
      end

      def default_template
        @template
      end

    end
  end
end
