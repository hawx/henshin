module Henshin

  # A post, stored in the /posts folder.
  module Post
    extend FileAttributes

    requires :title, :date

    TEMPLATE = 'post'

    # Renders the file contents using {RedcarpetEngine} then applies the 'post'
    # template if it exists, falling back to the 'default' template.
    #
    # @return [String] Rendered text for the post.
    def text
      res  = super
      data = dup

      (class << data; self; end).send(:define_method, :text) { res }

      @site.template TEMPLATE, data
    end

    def rss_date
      date.rfc2822
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
      Path @site.url_root, title.slugify, 'index.html'
    end

    # Compares posts on date, then on permalink if dates are the same.
    def <=>(other)
      c = other.respond_to?(:date) ? other.date <=> date : 0
      c.zero? ? super : c
    end

  end

  File.apply %r{(^|/)posts/}, Post

end
