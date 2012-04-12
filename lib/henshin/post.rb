module Henshin

  class Post < RedcarpetFile

    def text
      file_data = data.merge(:yield => super)
      template  = @site.template('post')
      SlimEngine.render template.text, file_data
    end

    def title
      yaml[:title] or UI.fail(inspect + " does not have a title.")
    end

    def date
      yaml[:date]  or UI.fail(inspect + " does not have a date.")
    end

    def tags
      yaml[:tags] || [yaml[:tag]].compact
    end

    def tag?(name)
      tags.include?(name)
    end

    def permalink
      "/#{title.slugify}/index.html"
    end

    def <=>(other)
      c = other.date <=> date
      if c.zero?
        c = permalink <=> other.permalink
      end
      c
    end

    include Comparable

    def inspect
      "#<Henshin::Post #{@path.to_s}>"
    end

  end
end
