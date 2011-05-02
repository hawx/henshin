require 'spec_helper'

describe Henshin::Engine::Support::Highlighter do

  describe ".highlight" do
    it "returns marked up html", :renders => true do
      result = "<pre class=\"highlight ruby\"><code><span class=\"k\">def</span> <span class=\"nf\">sq</span><span class=\"p\">(</span><span class=\"n\">x</span><span class=\"p\">)</span>\n  <span class=\"n\">x</span> <span class=\"o\">*</span> <span class=\"n\">x</span>\n<span class=\"k\">end</span></code></pre>"
    
      subject.highlight("def sq(x)\n  x * x\nend\n", :ruby).should == result
    end
  end

end