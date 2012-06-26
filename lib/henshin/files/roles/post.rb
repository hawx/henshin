module Henshin

  # A post, stored in the /posts folder.
  module Post

    TEMPLATE = 'post'

    # Renders the file contents using {RedcarpetEngine} then applies the 'post'
    # template if it exists, falling back to the 'default' template.
    #
    # @return [String] Rendered text for the post.
    def text
      @site.template TEMPLATE, data.merge(yield: super)
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

    def next=(post)
      @next = post
    end

    def prev=(post)
      @prev = post
    end

    def next_post
      @next
    end

    def prev_post
      @prev
    end

    def path
      Path @site.url_root, "#{title.slugify}/index.html"
    end

    # Compares posts on date, then on permalink if dates are the same.
    def <=>(other)
      c = other.respond_to?(:date) ? other.date <=> date : 0
      c.zero? ? super : c
    end

  end

  File.apply %r{(^|/)posts/}, Post

end
