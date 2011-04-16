require 'spec_helper'

describe Henshin::Engine::Sass do

  subject { Henshin::Engine::Sass.new }
  
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

describe Henshin::Engine::Scss do

  subject { Henshin::Engine::Scss.new }

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