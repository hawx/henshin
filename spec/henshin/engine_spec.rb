require 'spec_helper'

describe Henshin::Engine do


  let(:broken) { Class.new { include Henshin::Engine } }
  subject {
    Class.new { 
      include Henshin::Engine 
      
      def render(c,d)
        "hi"
      end  
    }
  }
  
  describe "#render" do
    it "should raise error if not implemented" do
      expect {
        broken.new.render("", {})
      }.to raise_error NotImplementedError
    end
    
    it "should not raise error if implemented" do
      expect {
        subject.new.render('', {})
      }.not_to raise_error NotImplementedError
    end
  end
  
  describe ".render" do
    it "should call method on new instance" do
      subject.render('', {}).should == "hi"
    end
  end
  
  
  describe Henshin::Engine::MagicHash do
    subject {
      Henshin::Engine::MagicHash.new({
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

end