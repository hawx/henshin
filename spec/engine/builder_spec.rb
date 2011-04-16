require 'spec_helper'

describe Henshin::Engine::Builder do

  subject { Henshin::Engine::Builder.new }
  
  describe "#render" do
    it "returns the rendered content" do
      text = <<EOS
node {
  leaf(:size => 2)
}
EOS
      
      result = <<EOS
<node>
  <leaf size="2"/>
</node>
EOS
      
      subject.render(text, {}).should == result
    
    end
  end

end