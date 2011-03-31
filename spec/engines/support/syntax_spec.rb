require 'spec_helper'

describe Henshin::Engine::Support::Syntax do

  subject { Henshin::Engine::Support::Syntax.new("def sq(x)\nx * x\nend\n", :ruby) }
  
  describe "#highlight" do
    it "returns marked up html" do
    
      result = ""
      
      subject.highlight.should == result
    
    end
  end

end