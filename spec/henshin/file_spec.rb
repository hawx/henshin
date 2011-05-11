require 'spec_helper'

describe Henshin::File do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' }
  let(:dest)   { source + '_site' }
  let(:site)   { Henshin::Base.new({'dest' => dest, 'source' => source}) }

  subject { 
    mock_file Henshin::File.new(source + 'test.txt', site), "Hello I am a test"
  }
  
  describe "#initialize" do
    it "converts path to pathname" do
      Henshin::File.new('somewhere.txt', site).path.should be_kind_of Pathname
    end
    
    it "takes a block which is ran in the new instance" do
      Henshin::File.new('somewhere.txt', site) do 
        set :output, 'fake'
      end.output.should == 'fake'
    end
  end
  
  describe "#inspect" do
    it "returns a string with the class and path" do
      subject.inspect.should == "#<Henshin::File test.txt>"
    end
  end
  
  describe "#inject_payload" do
    it "adds the hash to the payload injects list" do
      subject.inject_payload({:test => true})
      subject.payload_injects.should include({:test => true})
    end
  end
  
  describe "#inject_data" do
    it "adds the hash to the data injects list" do
      subject.inject_data({:test => true})
      subject.data_injects.should include({:test => true})
    end
  end
  
  describe "#<=>" do
    let(:a)  { Henshin::File.new(source + 'a', site) }
    let(:a2) { Henshin::File.new(source + 'a', site) }
    let(:b)  { Henshin::File.new(source + 'b', site) }
  
    specify { (a <=> b).should == -1 }
    specify { (b <=> a).should == 1 }
    specify { (a <=> a2).should == 0 }
  end
  
  describe "#set" do
    it "calls the setter for the symbol given" do
      subject.should_receive(:content=).with("test")
      subject.set(:content, "test")
    end
  end
  
  describe "#apply" do
    it "adds the class to the applies list" do
      test_klass = Class.new
      subject.apply(test_klass)
      subject.applies.should == [test_klass]
    end
    
    it "gets the class for symbol and adds to applies list" do
      klass = Class.new
      Henshin.register_engine :whatever, klass
      subject.apply(:whatever)
      subject.applies.should == [klass]
    end
  end
  
  describe "#use" do
    it "adds the class to the uses list" do
      test_klass = Class.new
      subject.use(test_klass)
      subject.uses.map {|i| i.class}.should == [test_klass]
    end
  end
  
  it { should be_readable }
  it { should be_renderable }
  it { should be_writeable }
  
  describe "#layoutable?" do
    context "when yaml" do
      it "returns true" do
        subject.stub!(:has_yaml?).and_return(true)
        subject.should be_layoutable
      end
    end
    
    context "when no yaml" do
      it "returns false" do
        subject.stub!(:has_yaml?).and_return(false)
        subject.should_not be_layoutable
      end
    end
  end
  
  describe "#has_yaml?" do
    subject { 
      Henshin::File.new(source + 'test.txt', site)
    }
  
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
  
  describe "#rendered?" do
    context "when @rendered set" do
      before { subject.rendered = "hey" }
      it { should be_rendered }
    end
    
    context "when @rendered not set" do
      it { should_not be_rendered }
    end
  end
  
  
  describe "#write_path" do
    specify { subject.write_path.should be_kind_of Pathname }
  
    context "when output is html" do
      it "returns the relative path with /index.html added" do
        subject.stub!(:output).and_return('html')
        subject.write_path.to_s.should == "test/index.html"
      end
    end
    
    context "when not html file" do
      it "returns the relative path with the correct extension" do
        subject.stub!(:output).and_return('css')
        subject.write_path.to_s.should == "test.css"
      end
    end
  end
  
  
  describe "#find_layout" do
    let(:test_layout) { Henshin::Layout.new(source + 'test.liquid', site) }
    let(:default_layout) { Henshin::Layout.new(source + 'main.liquid', site) }
    
    before { subject.stub!(:layoutable?).and_return(true) }
  
    context "when layout set in data" do
      it "returns the correct layout" do
        subject.stub!(:data).and_return({'layout' => 'test'})
        subject.find_layout([default_layout, test_layout]).should == test_layout
      end
    end
    
    context "when no layout set" do
      it "returns the default layout" do
        subject.find_layout([default_layout, test_layout]).should == default_layout
      end
    end
  end
  
  describe "#relative_path" do
    it "returns the path relative to site.source" do
      subject.relative_path.to_s.should == 'test.txt'
    end
  end
  
  describe "#data" do
    it "should include yaml front matter" do
      subject.stub!(:has_yaml?).and_return(true)
      subject.stub!(:raw_content).and_return("---\nyaml: true\n---\nHello")
      subject.stub!(:yaml).and_return({'yaml' => true})
      subject.data.should include({'yaml' => true})
    end
    
    it "should include values returned by payload_keys" do
      keys = subject.payload_keys.map {|i| i.to_s }
      subject.data.keys.should == keys
    end
    
    it "should include injected data hashes" do
      subject.inject_data({:test => Hash})
      subject.data.should include({:test => Hash})
    end
    
    it "should include injected procs" do
      subject.inject_data { {:test => Proc} }
      subject.data.should include({:test => Proc})
    end
    
    context "when override data is set" do
      it "returns override data" do
        subject.data = {'override' => 3}
        subject.data.should == {'override' => 3}
      end
    end
  end
  
  describe "#payload" do
    it "should include site payload" do
      subject.payload.should include site.payload
    end
    
    it "should include file data" do
      subject.payload['file'].should == subject.data
    end
    
    it "should include file data using correct key" do
      subject.key = :test
      subject.payload['test'].should == subject.data
    end
    
    it "should include injected payload hashes" do
      subject.inject_payload({:test => Hash})
      subject.payload.should include({:test => Hash})
    end
    
    it "should include injected payload procs" do
      subject.inject_payload { {:test => Proc} }
      subject.payload.should include({:test => Proc})
    end
  end
  
  describe "#yaml_text" do
    before do
      subject.stub!(:can_read?).and_return(true) 
      subject.path.stub!(:read).and_return("---\ntest: true\n---\nHello I am text")
    end
    
    it "returns the yaml frontmatter" do
      subject.yaml_text.should == "---\ntest: true\n---\n"
    end
  end
  
  describe "#yaml" do
    before do
      subject.stub!(:can_read?).and_return(true) 
      subject.path.stub!(:read).and_return("---\ntest: true\n---\nHello I am text")
    end
  
    it "returns a hash of loaded yaml frontmatter" do
      subject.yaml.should == {'test' => true}
    end
  end
  
  describe "#content" do
    context "when rendered" do
      it "returns rendered content" do
        subject.rendered = "I am rendered"
        subject.content.should == "I am rendered"
      end
    end
    
    context "when override content set" do
      it "returns the override content" do
        subject.content = "Override"
        subject.content.should == "Override"
      end
    end
    
    it "returns #raw_content" do
      subject.content.should == subject.raw_content
    end
  end
  
  describe "#raw_content" do
    context "when override content" do
      it "returns the override content" do
        subject.content = "Override"
        subject.raw_content.should == "Override"
      end
    end
    
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
  
  describe "#extension" do
    it "returns the file's extension" do
      subject.extension.should == "txt"
    end
  end
  
  describe "#mime" do
    it "returns the mime type for the output" do
      subject.stub!(:output).and_return('html')
      subject.mime.should == "text/html"
    end
  end
  
  describe "#url" do
    context "when a html file" do
      it "returns a pretty url" do
        subject.stub!(:output).and_return('html')
        subject.url.should == "/test"
      end
    end
    
    context "when an other file type" do
      it "returns the permalink" do
        subject.url.should == "/test.txt"
      end
    end
    
    it "should be possible to set url" do
      subject.set :url, '/somewhere.md'
      subject.url.should == '/somewhere.md'
    end
  end
  
  describe "#permalink" do
    it "returns the write path prepended with a /" do
      subject.permalink == "/test.txt"
    end
    
    it "should be possible to set permalink indirectly" do
      subject.set :url, '/somewhere.md'
      subject.permalink.should == '/somewhere.md'
    end
  end
  
  describe "#title" do
    it "returns a capitalised name for the file" do
      subject.title.should == "Test"
    end
    
    it "should be possible to set title" do
      subject.set :title, 'hey'
      subject.title.should == 'hey'
    end
  end
  
  describe "#output" do
    it "returns the extension" do
      subject.output.should == "txt"
    end
    
    it "should be possible to set output" do
      subject.set :output, 'other'
      subject.output.should == 'other'
    end
  end
  
  describe "#plural_key" do
    it "returns the pluralised singular_key" do
      subject.plural_key.should == "files"
    end
    
    it "should be possible to set indirectly" do
      subject.set :key, 'other'
      subject.plural_key.should == 'others'
    end
  end
  
  describe "#singular_key" do
    it "returns the key as a string" do
      subject.singular_key.should == "file"
    end
    
    it "should be possible to set indirectly" do
      subject.set :key, 'other'
      subject.singular_key.should == 'other'
    end
  end
  
  describe "#key" do  
    context "when a key has been set" do    
      before { subject.key = :test }
      
      it "returns the set key" do
        subject.key.should == :test
      end
    end
    
    context "when no key has been set" do
      specify { subject.key.should == :file }
    end
  end
  
  describe "#render" do
    context "when not rendered" do
      it "resets the rendered content" do
        subject.should_receive(:raw_content).and_return("called")
        subject.render
        subject.instance_variable_get("@rendered").should == "called"
      end
    
      it "runs the applies" do
        subject.should_receive(:run_applies)
        subject.render
      end
      
      it "runs the uses" do
        subject.should_receive(:run_uses)
        subject.render
      end
    end
    
    context "when already rendered" do
      before { subject.instance_variable_set("@rendered", "rendered") }
      
      it "resets the rendered content" do
        subject.should_not_receive(:raw_content)
        subject.render
      end
    
      it "doesn't run the applies" do
        subject.should_not_receive(:run_applies)
        subject.render
      end
      
      it "doesn't run the uses" do
        subject.should_not_receive(:run_uses)
        subject.render
      end
      
      context "when forced" do
        it "resets the rendered content" do
          subject.should_receive(:raw_content).and_return("called")
          subject.render(true)
          subject.instance_variable_get("@rendered").should == "called"
        end
      
        it "runs the applies" do
          subject.should_receive(:run_applies)
          subject.render(true)
        end
        
        it "runs the uses" do
          subject.should_receive(:run_uses)
          subject.render(true)
        end
      end
    end
  end
  
  describe "#run_applies" do
    let(:engine) {
      Class.new {
        implements Henshin::Engine
        
        def render(c, d)
          "#{c} done"
        end
      }
    }
  
    before { subject.apply(engine) }
  
    it "runs each engine" do
      engine.should_receive(:render)
      subject.run_applies
    end
    
    it "sets the rendered content" do
      subject.run_applies
      subject.content.should == "Hello I am a test done"
    end
  end
  
  describe "#run_uses" do
    let(:klass) {
      Class.new {
        def make(file)
          file.content = "Made"
        end
      }.new
    }
    
    before { subject.instance_variable_set("@uses", [klass]) }
    
    it "runs each class" do
      klass.should_receive(:make)
      subject.run_uses
    end
    
    it "alters the file" do
      subject.run_uses
      subject.content.should == "Made"
    end
  end
  
  describe "#layout" do
    context "when passed a layout" do
      it "sets the rendered content" do
        layout = Henshin::Layout.new(site.source + 'main.liquid', site)
        layout.should_receive(:render_with).with(subject)
        subject.layout(layout)
      end
    end
    
    context "when passed a boolean" do
      it "sets whether the file can use a layout" do
        subject.layout(true)
        subject.should be_layoutable
      end
    end
  end
  
  describe "#write" do
    
    before { 
      # Tried let but it wasn't working, so fell back to @var
      @file = File.new(site.source + subject.path, 'w')
      FileUtils.stub!(:mkdir_p).and_return(nil)
      File.stub!(:new).and_return(@file)
    }
    
    # Remove the file that gets written
    after { FileUtils.rm(site.source + subject.path) }
  
    it "creates the directories" do
      FileUtils.should_receive(:mkdir_p).with (site.source + subject.write_path).dirname
      subject.write(site.source)
    end
    
    it "creates a new file" do
      File.should_receive(:new).with(site.source + subject.write_path, 'w')
      subject.write(site.source)
    end
    
    it "writes the content" do
      @file.should_receive(:puts).with(subject.content)
      subject.write(site.source)
    end
  end

end
