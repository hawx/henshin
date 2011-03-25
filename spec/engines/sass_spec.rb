require 'spec_helper'

describe Henshin::Sass do

  subject { Henshin::Sass.new }
  
  describe "#render" do
    it "returns the rendered content" do
      text = <<EOS
body
  color: red 
EOS
  
      result = <<EOS
body {
  color: red; }
EOS
  
      subject.render(text, {}).should == result
    end
  end

end

describe Henshin::Scss do

  subject { Henshin::Scss.new }

  describe "#render" do
    it "returns the rendered content" do
      text = <<EOS
body {
  color: red 
}
EOS
  
      result = <<EOS
body {
  color: red; }
EOS
  
      subject.render(text, {}).should == result
    end
  end

end