# Edits the output from markdown files to work with SyntaxHighlighter.
class ModifiedRedcarpetFile < TiltFile
  def text
    super.gsub /<code class="(.*)">/ do
      "<code class='brush: #{$1}'>"
    end
  end
end

File.register /\.(md|mkd|markdown)\Z/, ModifiedRedcarpetFile
