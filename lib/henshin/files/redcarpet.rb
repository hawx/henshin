require 'redcarpet'

module Henshin

  # Uses {RedcarpetEngine} to render text.
  class RedcarpetFile < File

    # @return [String] Html rendered from the markdown source.
    def text
      engine = Redcarpet::Markdown.new(Redcarpet::Render::HTML, @site.config[:redcarpet])
      engine.render(super)
    end

    def extension
      '.html'
    end
  end

  File.register /\.md/, RedcarpetFile

end
