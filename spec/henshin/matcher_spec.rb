require 'spec_helper'

describe Henshin::Matcher do

  subject {
    Henshin::Matcher.new('/:first/**/:second/*/:name.*')
  }
  
  describe "#initialize" do
    it "creates choices from {a,b,..} style lists" do
      m = Henshin::Matcher.new('/{blog,site}/*.*')
      m.matches?('/blog/a.b').should be_true
      m.matches?('/what/a.b').should be_false 
    end
  end

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
    
    it "returns matches in captures key when regex used" do
      m = Henshin::Matcher.new(/a(.*)d\s1(\d+)4/)
      m.matches('abcd 1234').should == {'captures' => ['bc', '23']}
    end
    
    it "returns an empty hash when no captures" do
      m = Henshin::Matcher.new(/abc/)
      m.matches('abc').should == {}
    end
    
    it "returns false when no match" do
      subject.matches('/what/what/hey').should be_false
    end
  end
  
  describe "#regex" do
    specify { subject.regex.should be_kind_of Regexp }
  end
  
  describe "#to_s" do
    it "returns the passed string" do
      subject.to_s.should == '/:first/**/:second/*/:name.*'
    end
  end
  
end