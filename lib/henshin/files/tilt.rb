module Henshin

  class File

    # Renders a file using an engine from Tilt. This particular class deals
    # with file types which would never use templates.
    #
    # @see http://github.com/rtomayko/tilt
    class Tilt < File

      EXTENSIONS = %w(sass scss less coffee).map(&:to_sym)

      # Renders the files text using the appropriate Tilt engine. Also gets the
      # configuration for the engine, if any, from {Site#config}.
      #
      # @return [String] The rendered file contents
      def text
        ext    = @path.extname[1..-1].to_sym
        config = (@site.config[ext] || {}).to_hash.symbolise
        ::Tilt[ext].new(nil, nil, config) { super }.render
      end
    end

    register /\.(#{Tilt::EXTENSIONS.join('|')})\Z/, Tilt


    # Renders a file using an engine from Tilt. This class, unlike {Tilt} deals
    # with file types which generally would use a template. To prevent a
    # template being used, you need to add to the YAML frontmatter:
    #
    #     template: none
    #
    # And to use a different template than 'default' simply use the template's
    # name instead of "none". For example, to use the template "page" I would
    # add:
    #
    #     template: page
    #
    class TiltWithTemplate < Tilt
      include Templatable

      EXTENSIONS = %w(str markdown mkd md textile rdoc wiki
                      creaole mediawiki mw).map(&:to_sym)

    end

    register /\.(#{TiltWithTemplate::EXTENSIONS.join('|')})\Z/, TiltWithTemplate

  end
end
