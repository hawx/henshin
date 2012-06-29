module Henshin

  class TiltFile < File

    EXTENSIONS = %s(str
                    erb rhtml erubis
                    haml
                    sass scss less
                    coffee
                    nokogiri
                    builder
                    mad
                    liquid
                    radius
                    markdown mkd md
                    textile
                    rdoc
                    wiki creole
                    mediawiki mw
                    yajl)

    def text
      ext = path.extension[1..-1].to_sym
      Tilt[ext].new(nil, nil, @site.config[ext]) { super }.render
    end

  end

  File.register /#{TiltFile::EXTENSIONS.join('|')/, TiltFile

end
