require 'spec_helper'

describe Henshin::Engine::Support::Uv do

  subject { Henshin::Engine::Support::Uv.new("def sq(x)\nx * x\nend\n", :ruby) }
  
  describe "#highlight" do
    it "returns marked up html" do
    
      result = "<span class=\"ControlKeyword\">def</span> <span class=\"FunctionName\">sq</span><span class=\"Punctuation\">(</span><span class=\"FunctionArgument\">x</span><span class=\"Punctuation\">)</span>\nx <span class=\"KeywordOperator\">*</span> x\n<span class=\"ControlKeyword\">end</span>\n"
      
      subject.highlight.should == result
    
    end
  end

end