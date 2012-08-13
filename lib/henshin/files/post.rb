module Henshin

  class File
    # A post, stored in the /posts folder.
    module Post
      include Templatable
      extend  FileAttributes

      requires :title, :date
      template 'post'

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

      def published?
        true
      end

      def path
        style = @site.config[:permalink]

        data = {
          year:  date.strftime('%Y'),
          month: date.strftime('%m'),
          day:   date.strftime('%d'),
          title: title.slugify
        }

        url = data.inject(style) {|res, (tok, val)|
          res.gsub /:#{Regexp.escape(tok)}/, val
        }

        Path @site.root, url
      end

      # Compares posts on date, then on permalink if dates are the same.
      def <=>(other)
        c = other.respond_to?(:date) ? other.date <=> date : 0
        c.zero? ? super : c
      end

    end

    apply %r{(^|/)posts/}, Post

  end
end
