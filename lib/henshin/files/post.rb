module Henshin

  # A post, stored in the /posts folder.
  class Post < RedcarpetFile

    # Renders the file contents using {RedcarpetEngine} then applies the 'post'
    # template if it exists, falling back to the 'default' template.
    #
    # @return [String] Rendered text for the post.
    def text
      file_data = @site.data.merge(data.merge(:yield => super))
      template  = @site.template('post')
      SlimEngine.render template.text, file_data
    end

    # @return [String] Title for the post.
    def title
      yaml[:title] or UI.fail(inspect + " does not have a title.")
    end

    # @return [Date] Date for the post.
    def date
      yaml[:date]  or UI.fail(inspect + " does not have a date.")
    end

    # @return [Array<String>] Tags for the post.
    def tags
      yaml[:tags] || [yaml[:tag]].compact
    end

    def data
      tags = @site.tags.files.find_all {|i| tag?(i.name) }.sort.map(&:basic_data)
      super.merge(tags: tags)
    end

    # @param name [String] Name of tag to check for.
    # @return Whether the post has the tag given.
    def tag?(name)
      tags.include?(name)
    end

    # @example
    #
    #   post = Post.new(site, "posts/hello-world.md")
    #   post.permalink #=> "/hello-world/index.html"
    #
    # @return [String] Permalink for the post.
    def permalink
      "#{@site.url_root}#{title.slugify}/index.html"
    end

    # Compares posts on date, then on permalink if dates are the same.
    def <=>(other)
      c = other.respond_to?(:date) ? other.date <=> date : 0
      c.zero? ? super : c
    end

  end
end