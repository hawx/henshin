require 'spec_helper'

describe Henshin::Engine::Support::Syntax do

  subject { Henshin::Engine::Support::Syntax.new("def sq(x)\nx * x\nend\n", :ruby) }
  
  describe "#highlight" do
    it "returns marked up html", :renders => true do
    
      result = "<span class=\"keyword\">def </span><span class=\"method\">sq</span><span class=\"punct\">(</span><span class=\"ident\">x</span><span class=\"punct\">)</span>\n<span class=\"ident\">x</span> <span class=\"punct\">*</span> <span class=\"ident\">x</span>\n<span class=\"keyword\">end</span>\n"
      
      subject.highlight.should == result
    
    end
  end
  
  describe ".available?" do
    it "returns true if gem installed" do
      described_class.should_receive(:require).with("syntax").and_return(true)
      described_class.should be_available
    end
    
    it "returns false if gem not installed" do
      described_class.should_receive(:require).with("syntax").and_raise(LoadError)
      described_class.should_not be_available
    end
  end

end