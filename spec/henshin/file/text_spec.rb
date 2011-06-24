require 'spec_helper'

describe Henshin::File::Text do

  subject { mock_file Henshin::File::Text.new('file.txt', nil) }

  it { should be_readable }
  it { should be_renderable }
  it { should be_writeable }
  
  describe "#layoutable?" do
    context "when yaml" do
      before { subject.stub!(:has_yaml?).and_return(true) }
      it { should be_layoutable }
    end
    
    context "when no yaml" do
      before { subject.stub!(:has_yaml?).and_return(false) }
      it { should_not be_layoutable }
    end
    
    it "can be set" do
      subject.set :layout, true
      subject.should be_layoutable
      subject.set :layout, false
      subject.should_not be_layoutable
    end
  end
  
  describe "#has_yaml?" do
    context "when file begins '---'" do
      before { subject.path.stub!(:read).and_return("---") }
      it { should have_yaml }
    end
    
    context "when file doesn't begin '---'" do
      before { subject.path.stub!(:read).and_return("xyz") }
      it { should_not have_yaml }
    end
    
    context "when file is not readable" do
      before { subject.stub!(:readable?).and_return(false) }
      it { should_not have_yaml }
    end
  end
  
  describe "#yaml_text" do
    before do
      subject.stub!(:has_yaml?).and_return(true)
      subject.path.stub!(:read).and_return("---\ntest: true\n---\nHello I am text")
    end
    
    it "returns the yaml frontmatter" do
      subject.yaml_text.should == "---\ntest: true\n---\n"
    end
  end
  
  describe "#yaml" do
    before { subject.stub!(:yaml_text).and_return("---\ntest: true\n---\n") }
  
    it "returns a hash of loaded yaml frontmatter" do
      subject.yaml.should == {'test' => true}
    end
  end
  
  describe "#content" do
    context "when content set" do
      it "returns the content" do
        subject.content = "Override"
        subject.content.should == "Override"
      end
    end
    
    it "returns #raw_content" do
      subject.content.should == subject.raw_content
    end
  end
  
  describe "#raw_content" do    
    context "when has yaml" do
      it "returns the content without the yaml frontmatter" do
        subject.path.stub!(:read).and_return("---\nyaml: me\n---\nReal content")
        subject.stub!(:has_yaml?).and_return(true)
        subject.raw_content.should == "Real content"
      end
    end
    
    context "when not readable" do
      it "returns an empty string" do
        subject.stub!(:readable?).and_return(false)
        subject.raw_content.should == ""
      end
    end
    
    it "returns the content" do
      subject.path.stub!(:read).and_return("I am content")
      subject.raw_content.should == "I am content"
    end
  end
  
  describe "#data" do
    it "should include yaml front matter" do
      subject.stub!(:has_yaml?).and_return(true)
      subject.stub!(:raw_content).and_return("---\nyaml: true\n---\nHello")
      subject.stub!(:yaml).and_return({'yaml' => true})
      subject.data.should include({'yaml' => true})
    end
  end

end