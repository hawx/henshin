module Henshin

  # Uses the {SlimEngine} to render text.
  class SlimFile < File

    # Renders the slim source with the file's data. Applies a template to the
    # result unless the yaml contains +template: none+.
    #
    # @return [String] Html compiled from the slim source and data.
    def text
      text = Engines.render(:slim, super, @site.data.merge(data))

      return text if data[:template] == "none"
      @site.template data[:template], data.merge(:yield => text)
    end

    def path
      Path @site.url_root, super.to_s.sub(/\.slim$/, '.html')
    end
  end

  File.register /\.slim/, SlimFile

end
