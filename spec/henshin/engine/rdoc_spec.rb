require 'spec_helper'

describe Henshin::Engine::RDoc do
  
  subject { Henshin::Engine::RDoc.new }
  
  describe "#render" do
    it "returns the rendered content", :renders => true do
      text = <<EOS
= Header

Yes _rdoc_

EOS

      result = <<EOS
<h1>Header</h1>
<p>
Yes <em>rdoc</em>
</p>
EOS

      subject.render(text, {}).should == result
    
    end
  end

end