require 'spec_helper'

describe Henshin::Matcher do

  subject {
    Henshin::Matcher.new('/:first/**/:second/*/:name.*')
  }

  describe "#matches?" do
    it "returns true when match" do
      subject.matches?('/something/many/folders/2/a folder/I-am.md').should be_true
    end
    
    it "returns false when no match" do
      subject.matches?('/f/s/hey.txt').should be_false
    end
  end
  
  describe "#matches" do
    it "returns matches when match" do
      subject.matches('/something/many/folders/2/a folder/I-am.md').should == {
        'splat' => ['many/folders/', 'a folder', 'md'],
        'first' => 'something',
        'second' => '2',
        'name' => 'I-am'
      }
    end
    
    it "returns false when no match" do
      subject.matches('/what/what/hey').should be_false
    end
  end
  
  describe "#to_s" do
    it "returns the passed string" do
      subject.to_s.should == '/:first/**/:second/*/:name.*'
    end
  end
  
end