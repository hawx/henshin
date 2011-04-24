require 'spec_helper'

describe Henshin::Engine::Support::HighlightScanner do

  subject do
    Henshin::Engine::Support::HighlightScanner.new <<EOS
Some plain text

$ highlight ruby
def sq(x)
  x * x
end
$ end

Some plain text
EOS
  end
  
  describe "#highlight" do
    it "returns marked up html" do
      
      result = "Some plain text\n\n<pre class=\"highlight ruby\"><code><span class=\"k\">def</span> <span class=\"nf\">sq</span><span class=\"p\">(</span><span class=\"n\">x</span><span class=\"p\">)</span>\n  <span class=\"n\">x</span> <span class=\"o\">*</span> <span class=\"n\">x</span>\n<span class=\"k\">end</span></code></pre>\n\nSome plain text\n"
      
      subject.highlight.should == result
    
    end
  end

end