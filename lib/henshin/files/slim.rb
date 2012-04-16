module Henshin

  class SlimFile < File
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

    def url
      super.sub /index\.html$/, ''
    end

    def extension
      '.html'
    end
  end

  File.register '.slim', SlimFile

end
