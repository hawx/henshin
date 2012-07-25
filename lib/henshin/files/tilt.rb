module Henshin

  class TiltFile < File

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
      Tilt[ext].new(nil, nil, config) { super }.render
    end

  end

  class TiltTemplateFile < File

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

      text = Tilt[ext].new(nil, nil, (@site.config[ext] || {}).to_hash.symbolise) {
        super
      }.render(scope) { scope.yield }

      return text if scope.template == 'none'

      @site.template(scope.template, Henshin::DEFAULT_TEMPLATE).render(data)
    end

  end

  File.register /\.(#{TiltFile::EXTENSIONS.join('|')})\Z/, TiltFile
  File.register /\.(#{TiltTemplateFile::EXTENSIONS.join('|')})\Z/, TiltTemplateFile

end
