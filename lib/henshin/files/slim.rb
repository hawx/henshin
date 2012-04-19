module Henshin

  # Uses the {SlimEngine} to render text.
  class SlimFile < File

    # Renders the slim source with the file's data. Applies a template to the
    # result unless the yaml contains +template: none+.
    #
    # @return [String] Html compiled from the slim source and data.
    def text
      text = SlimEngine.render super, @site.data.merge(data)

      if data[:template] != "none"
        file_data = @site.data.merge(data.merge(:yield => text))
        template = @site.template(data[:template])
        SlimEngine.render template.text, file_data
      else
        text
      end
    end

    # @return [String] The pretty url with the 'index.html' part.
    def url
      super.sub /index\.html$/, ''
    end

    def extension
      '.html'
    end
  end

  File.register '.slim', SlimFile

end
