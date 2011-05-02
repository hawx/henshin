require 'spec_helper'

describe Henshin::Engine::CoffeeScript do
  
  subject { Henshin::Engine::CoffeeScript.new }
  
  describe "#render" do
    it "returns the rendered content", :renders => true do
      text = <<EOS
sq = (x) -> x * x   
EOS
      result = <<EOS
(function() {
  var sq;
  sq = function(x) {
    return x * x;
  };
}).call(this);
EOS
    
      subject.render(text, {}).should == result
    end
  end

end