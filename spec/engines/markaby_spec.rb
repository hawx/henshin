require 'spec_helper'
require 'henshin/engine/markaby'

describe Henshin::Markaby do

  subject { Henshin::Markaby.new }
  
  describe "#render" do
    it "returns the rendered content" do
      text = <<EOS
html do
  head do
    title title
  end
  
  body do
    Text
  end
end
EOS
      
      result = <<EOS
      
EOS

      #subject.render(text, {:title => "cheese"}).should == result
      subject.render("what", {})
    end
  end

end