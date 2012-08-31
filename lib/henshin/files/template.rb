module Henshin

  class File

    # Used to extend template files. These will generally be written in a language
    # such as slim, as they have the ability to include data.
    #
    # @example
    #
    #   t = SlimFile.new(site, path)
    #   t.extend Template
    #
    #   t.template other_file
    #   #=> "..."
    #
    module Template

      # Name used to refer to the template.
      # @return [String]
      def name
        @path.basename.to_s.split('.').first
      end

      # Sets the data and then uses the superclasses #text method to render the
      # template.
      #
      # @param data [Hash]
      def template(data)
        data.template = 'none'
        @data = data.safe
        text
      end

      alias_method :render, :template

      # @return [Hash] The data set by #template.
      def data
        @data
      end
    end

    apply %r{(^|/)templates/}, Template

  end
end
