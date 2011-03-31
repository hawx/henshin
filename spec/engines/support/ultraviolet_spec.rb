require 'spec_helper'

describe Henshin::Engine::Support::Uv do

  subject { Henshin::Engine::Support::Uv.new("def sq(x)\nx * x\nend\n", :ruby) }
  
  describe "#highlight" do
    it "returns marked up html" do
    
      result = ""
      
      subject.highlight.should == result
    
    end
  end

end