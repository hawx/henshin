# Edits the output from markdown files to work with SyntaxHighlighter.
class ModifiedRedcarpetEngine < RedcarpetEngine
  def render(*args)
    super.gsub('<code class="ruby">', '<code class="brush: ruby">')
  end
end

Engines.register :redcarpet, ModifiedRedcarpetEngine
