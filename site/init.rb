# Edits the output from markdown files to work with SyntaxHighlighter.
class ModifiedRedcarpetFile < RedcarpetFile
  def text
    super.gsub('<code class="ruby">', '<code class="brush: ruby">')
  end
end

File.register /\.md/, ModifiedRedcarpetFile
