require 'spec_helper'

describe Henshin::Engine::Nokogiri do
  
  subject { Henshin::Engine::Nokogiri.new }
  
  describe "#render" do
    it "returns the rendered content", :renders => true do
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