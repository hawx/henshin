module Henshin

  # A post, stored in the /posts folder.
  module Post
    extend FileAttributes

    requires :title, :date
    template 'post'

    # Renders the file contents using {RedcarpetEngine} then applies the 'post'
    # template if it exists, falling back to the 'default' template.
    #
    # @return [String] Rendered text for the post.
    def text
      res  = super
      data = clone

      data.singleton_class.send(:define_method, :text) { res }

      default = nil
      singleton_class.ancestors.find {|klass|
        default = klass.default_template if klass.respond_to?(:default_template)
      }

      @site.template(default, Henshin::DEFAULT_TEMPLATE, true).render(data)
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
      Path @site.root, title.slugify, 'index.html'
    end

    # Compares posts on date, then on permalink if dates are the same.
    def <=>(other)
      c = other.respond_to?(:date) ? other.date <=> date : 0
      c.zero? ? super : c
    end

  end

  File.apply %r{(^|/)posts/}, Post

end
