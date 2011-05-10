require 'spec_helper'

describe Henshin::Engine::Support::CodeRay do

  subject { Henshin::Engine::Support::CodeRay.new("def sq(x)\nx * x\nend\n", :ruby) }

  describe "#highlight" do
    it "returns marked up html", :renders => true do
    
      result = "<span class=\"r\">def</span> <span class=\"fu\">sq</span>(x)\nx * x\n<span class=\"r\">end</span>\n"

      subject.highlight.should == result
    end
  end
  
  describe ".available?" do
    it "returns true if gem installed" do
      described_class.should_receive(:require).with("coderay").and_return(true)
      described_class.should be_available
    end
    
    it "returns false if gem not installed" do
      described_class.should_receive(:require).with("coderay").and_raise(LoadError)
      described_class.should_not be_available
    end
  end

end