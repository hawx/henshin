require 'slim'

module Henshin

  # Uses the {SlimEngine} to render text.
  class SlimFile < File

    def data
      self
    end

    # Renders the slim source with the file's data. Applies a template to the
    # result unless the yaml contains +template: none+.
    #
    # @return [String] Html compiled from the slim source and data.
    def text
      scope = @site.data_for(data)

      text = Tilt[:slim].new(nil, nil, @site.config[:slim]) {
        super
      }.render(scope) {
        scope.yield
      }

      return text if scope.template == 'none'

      @site.template(scope.template, data)
    end
  end

  File.register /\.slim/, SlimFile

end
