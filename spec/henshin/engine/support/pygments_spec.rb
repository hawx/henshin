require 'spec_helper'

describe Henshin::Engine::Support::Pygments do

  subject { Henshin::Engine::Support::Pygments.new("def sq(x)\nx * x\nend\n", :ruby) }

  describe "#highlight" do
    it "returns marked up html", :renders => true do
    
      result = "<span class=\"k\">def</span> <span class=\"nf\">sq</span><span class=\"p\">(</span><span class=\"n\">x</span><span class=\"p\">)</span>\n<span class=\"n\">x</span> <span class=\"o\">*</span> <span class=\"n\">x</span>\n<span class=\"k\">end</span>"

      subject.highlight.should == result
    
    end
  end
  
  describe ".available?" do
    it "returns true if pygments installed" do
      subject.stub!(:`).and_return("/usr/bin/pygmentize")
      described_class.should be_available
    end
    
    it "returns false if pygments not installed" do
      subject.stub!(:`).and_return("pygmentize not found")
      described_class.should_not be_available
    end
  end

end