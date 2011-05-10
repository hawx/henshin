require 'spec_helper'

describe Henshin::Engine::Support::Uv do

  subject { Henshin::Engine::Support::Uv.new("def sq(x)\nx * x\nend\n", :ruby) }
  
  describe "#highlight" do
    it "returns marked up html", :renders => true do
    
      result = "<span class=\"ControlKeyword\">def</span> <span class=\"FunctionName\">sq</span><span class=\"Punctuation\">(</span><span class=\"FunctionArgument\">x</span><span class=\"Punctuation\">)</span>\nx <span class=\"KeywordOperator\">*</span> x\n<span class=\"ControlKeyword\">end</span>\n"
      
      subject.highlight.should == result
    
    end
  end
  
  describe ".available?" do
    it "returns true if gem installed" do
      described_class.should_receive(:require).with("uv").and_return(true)
      described_class.should be_available
    end
    
    it "returns false if gem not installed" do
      described_class.should_receive(:require).with("uv").and_raise(LoadError)
      described_class.should_not be_available
    end
  end

end