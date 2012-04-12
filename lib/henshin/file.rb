module Henshin

  class File

    YAML_REGEX = /\A---\n^(.*?)\n^---\n?(.*)\z/m

    attr_reader :path

    # @param site [Site]
    # @param path [Pathname, String]
    def initialize(site, path)
      @site = site
      @path = Pathname.new(path)
    end

    # @return [Array<String>] An array of two parts. The first is the yaml part
    # of the file, the second is the text part.
    def read
      contents = @path.read || ""
      if match = contents.match(YAML_REGEX)
        match.to_a[1..2]
      else
        ['', contents]
      end
    end

    # return [Hash]
    def yaml
      (YAML.load(read[0]) || {}).symbolise
    end

    # @return [Hash]
    def data
      {
        mime:      mime,
        url:       url,
        permalink: permalink
      }.merge(yaml)
    end

    # @return [String] Extension for the file to be written.
    def extension
      @path.extname
    end

    # @return [String] The mime type for the file to be written.
    def mime
      Rack::Mime.mime_type extension
    end

    # @return [String] Text of the file.
    def text
      read[1]
    end

    # @retrun [String] Absolute url to the file, including 'index.html'.
    def permalink
      "/#{@path.relative_path_from(@site.root)}".sub(@path.extname, extension)
    end

    # @return [String] Pretty url to the file.
    def url
      permalink
    end

    # @param dir [String, Pathname] Directory the site is being built in.
    # @return [Pathname]
    def write_path(dir)
      @site.root + dir + permalink[1..-1]
    end

    def write(dir)
      Writer.write write_path(dir), text
      UI.wrote permalink[1..-1]
    end

  end
end
