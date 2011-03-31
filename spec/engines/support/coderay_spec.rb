require 'spec_helper'

describe Henshin::Engine::Support::CodeRay do

  subject { Henshin::Engine::Support::CodeRay.new("def sq(x)\nx * x\nend\n", :ruby) }

  describe "#highlight" do
    it "returns marked up html" do
    
      result = "<div class=\"CodeRay\">\n  <div class=\"code\"><pre><span class=\"r\">def</span> <span class=\"fu\">sq</span>(x)\nx * x\n<span class=\"r\">end</span>\n</pre></div>\n</div>\n"

      subject.highlight.should == result
    end
  end
  
  describe ".available?" do
    it "returns true if gem installed" do
      Kernel.stub!(:require).and_return(true)
      described_class.should be_available
    end
    
    it "returns false if gem not installed" do
      Kernel.stub!(:require).and_raise(LoadError)
      described_class.should_not be_available
    end
  end

end