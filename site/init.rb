# -*- coding: utf-8 -*-
# Edits the output from markdown files to work with SyntaxHighlighter.

class ModifiedRedcarpetFile < File::TiltWithTemplate
  def text
    super.gsub /<code class="(.*)">/ do
      "<code class='brush: #{$1}'>"
    end
  end
end

File.register /\.(md|mkd|markdown)\Z/, ModifiedRedcarpetFile

module Helpers
  def format_date(date)
    date.strftime("%B %e, %Y")
  end

  def truncate(text, len=50, with='…')
    return text if text.length <= len

    str = ''
    text.split(' ').each do |word|
      if (str + word).length <= len
        str += ' ' + word
      else
        break
      end
    end

    str + with
  end
end
