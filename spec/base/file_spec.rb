require 'spec_helper'

describe Henshin::File do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:site)   { Henshin::Base.new({'dest' => dest, 'source' => source}) }

  subject { 
    Henshin::File.new(source + 'test.txt', site) 
  }
  
  describe "#extension" do
    specify { subject.extension.should be_kind_of String }
    it "returns the extension" do
      subject.extension.should == "txt"
    end
  end
  
  describe "#dependencies" do
    specify { subject.dependencies.should be_kind_of Array}
    it "returns a list of dependencies" do
      subject.dependencies.should == []
    end
  end
  
  describe "#content" do
    specify { subject.content.should be_kind_of String}
    context "when file has yaml frontmatter" do
      it "returns only content" do
        subject.path.stub!(:read).and_return("---\ntitle: Hi\n---\nI am the contents")
        subject.content == "I am the contents"
      end
    end
    
    context "when file has no yaml frontmatter" do
      it "returns all files contents" do
        subject.path.stub!(:read).and_return("I am the contents")
        subject.content == "I am the contents"
      end
    end
    
    context "when file has been rendered" do
      it "returns rendered contents" do
        subject.rendered = "I am rendered"
        subject.content == "I am rendered"
      end
    end
  end
  
  describe "#has_yaml?" do
    context "when file has yaml frontmatter" do
      it "returns true" do
        subject.path.stub!(:read).and_return("---")
        subject.has_yaml?.should be_true
      end
    end
    
    context "when file has no yaml frontmatter"  do
      it "returns false" do
        subject.path.stub!(:read).and_return("hi")
        subject.has_yaml?.should be_false
      end
    end
  end
  
  describe "#yaml" do
    specify { subject.content.should be_kind_of String }
    it "returns the yaml frontmatter" do
      subject.path.stub!(:read).and_return("---\ntitle: This\n---\nNot this\n")
      subject.yaml.should == "---\ntitle: This\n---\n"
    end
  end
  
  describe "#data" do
    specify { subject.data.should be_kind_of Hash }
    it "includes basic data" do
      subject.data.should include({
        'extension' => subject.extension, 
        'url' => subject.url,
        'permalink' => subject.permalink,
        'content' => subject.content,
        'title' => subject.title
      })
    end
  end
  
  describe "#payload" do
    specify { subject.data.should be_kind_of Hash }
    it "includes site payload" do
      subject.payload['site'].nil?.should be_false
    end
    
    it "includes data" do
      subject.payload['file'].should == subject.data
    end
    
    it "puts data in #key as well" do
      subject.payload[subject.singular_key].should == subject.data
    end
  end
  
  describe "#url" do
    specify { subject.url.should be_kind_of String }
    
    context "when output is html" do
      it "returns a pretty url" do
        subject.stub!(:output).and_return("html")
        subject.url.should == "/test"
      end
    end
    
    context "when output is not html" do
      it "returns the permalink" do
        subject.stub!(:output).and_return("js")
        subject.url.should == subject.permalink
      end
    end
  end
  
  describe "#permalink" do
    it "retuns absolute link to file" do
      subject.permalink == "/" + subject.write_path.to_s
    end
  end
  
  describe "#title" do
    it "returns name of file" do
      subject.title.should == "Test"
    end
  end
  
  describe "#relative_path" do
    specify { subject.relative_path.should be_kind_of Pathname }
    it "returns path relative to read directory" do
      subject.relative_path.should == Pathname.new('test.txt')
    end
  end
  
  describe "#render" do
    it "uses engine to render content" do
      subject.engine = lambda {|c,d| c = "rendered" }
      subject.render.should == "rendered"
    end
  end
  
  describe "#rendered?" do
    context "when file has rendered content" do
      it "returns true" do
        subject.rendered = "hey"
        subject.rendered?.should be_true
      end
    end
    
    context "when file has no rendered content" do
      it "returns false" do
        subject.rendered = nil
        subject.rendered?.should be_false
      end
    end
  end
  
  describe "#output" do
    context "when output set" do
      it "returns the output" do
        subject.output = "html"
        subject.output.should == "html"
      end
    end
    
    context "when no output is set" do
      it "defaults to #extension" do
        subject.output = nil
        subject.output.should == subject.extension
      end
    end
  end
  
  describe "#write_path" do
    specify { subject.write_path.should be_kind_of Pathname }
    
    context "when output is html" do
      it "returns path ending /index.html" do
        subject.output = "html"
        subject.write_path.to_s.should == "test/index.html"
      end
    end
    
    context "when output is not html" do
      it "returns #relative_path with correct extension" do
        subject.output = "js"
        subject.write_path.to_s.should == "test.js"
      end
    end
  end
  
  describe "#write" do
    
    # This bit is fairly ridiculous, but stick with it. I'm creating a
    # dummy class to mock the File instance that is created.
    let(:obj) {
      class Obj; def puts; end; end
      @obj = @obj || Obj.new
    }
  
    # Stub all the methods, then use expectations to test when they are called!
    before do
      FileUtils.stub!(:mkdir_p)
      ::File.stub!(:new).and_return(obj)
      obj.stub!(:puts).and_return(nil)
      Henshin::CLI.stub!(:print)
    end
  
    it "makes the directories" do
      FileUtils.should_receive(:mkdir_p).with(
        (Pathname(dest) + subject.write_path).dirname
      )
      subject.write(Pathname.new(dest))
    end
  
    it "create and write to file" do
      ::File.should_receive(:new).with(Pathname(dest) + subject.write_path, 'w')
      obj.should_receive(:puts).with(subject.content)
      subject.write(Pathname.new(dest))
    end
    
    it "shows output" do 
      Henshin::CLI.should_receive(:print)
      subject.write(Pathname.new(dest))
    end
  end
  
  describe "#layout" do
    it "returns the layout for the file" do
      subject.stub!(:layout?).and_return(true)
      subject.stub!(:data).and_return({'layout' => 'test'})
      layout = Henshin::Layout.new(source+"layouts/test.liquid", site)
      subject.layout([layout]).should == layout
    end
  end
  
  describe "#plural_key" do
    it "returns key pluralised" do
      subject.key = "test"
      subject.plural_key.should == "tests"
    end
  end
  
  describe "#singular_key" do
    it "returns the key" do
      subject.key = "test"
      subject.singular_key.should == "test"
    end
  end
  

end
