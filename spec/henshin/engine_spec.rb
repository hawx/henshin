require 'spec_helper'

describe Henshin::Engine do

  subject {
    Class.new(Henshin::Engine) {
      def render(c,d)
        "hi"
      end
    }
  }

  describe ".render" do
    it "should call #render on new instance" do
      subject.render('', {}).should == "hi"
    end
  end
end

describe Henshin::MagicHash do
  subject {
    Henshin::MagicHash.new({
      'site' => { 'title' => "Test Site" },
      'file' => { 'title' => "Test File" }
    })
  }

  describe "calling a method" do
    it "returns the value for the key" do
      subject.site.to_h.should == {'title' => 'Test Site'}
    end
  end

  describe "calling a nested method" do
    it "returns the value for the key" do
      subject.file.title.should == 'Test File'
    end
  end

  describe "if none existent key is called" do
    it "raises error" do
      expect {
        subject.what
      }.to raise_error NoMethodError
    end
  end

  describe "#[]" do
    it "returns the value for the key" do
      subject['site'].to_h.should == {'title' => 'Test Site'}
    end
  end
end
