module Henshin

  # Used to extend template files. These will generally be written in a language
  # such as slim, as they have the ability to include data.
  #
  # @example
  #
  #   t = SlimFile.new(site, path)
  #   t.extend Template
  #
  #   t.template :title => "Cool thing", :yield => "<p>Some content</p>"
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
      @data = data
      text
    end

    # @return [Hash] The data set by #template.
    def data
      @data
    end
  end

  File.apply %r{(^|/)templates/}, Template

end
