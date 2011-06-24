require 'spec_helper'

describe Henshin::File do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '../test_site' }
  let(:dest)   { source + '_site' }
  let(:site)   { Henshin::Base.new({'dest' => dest, 'source' => source}) }

  subject { 
    mock_file Henshin::File.new(source + 'test.txt', site), "Hello I am a test"
  }
  
  describe ".set" do
    subject {
      Class.new(Henshin::File) { set :output, 'what' }
    }
  
    it "allows values to be set for instances of a class" do
      subject.new(nil, nil).output.should == 'what'
    end
  end
  
  
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
    it "returns a string with the class and url" do
      subject.inspect.should == "#<Henshin::File /test.txt>"
    end
  end
  
  describe "#inject_payload" do
    it "adds the hash to the payload injects list" do
      subject.inject_payload({:test => true})
      subject.payload_injects.should include({:test => true})
    end
    
    context "if payload has been cached" do
      before { subject.payload }
    
      it "adds the hash to the cached payload hash" do
        subject.inject_payload({:test => true})
        subject.instance_variable_get(:@payload).should include({:test => true})
      end
      
      it "calls the proc and adds to the cached payload hash" do
        subject.inject_payload proc { {:test => true} }
        subject.instance_variable_get(:@payload).should include({:test => true})
      end
    end
  end
  
  describe ".inject_payload" do
    it "adds a payload to the injects list for the class" do
      subject.class.inject_payload({:class_inject => true})
      subject.payload.should include({:class_inject => true})
    end
  end
  
  describe "#inject_data" do
    it "adds the hash to the data injects list" do
      subject.inject_data({:test => true})
      subject.data_injects.should include({:test => true})
    end
    
    context "if data has been cached" do
      before { subject.data }
    
      it "adds the hash to the cached data if it exists" do
        subject.inject_data({:test => true})
        subject.instance_variable_get(:@data).should include({:test => true})
      end
      
      it "calls the proc and adds to the cached payload hash" do
        subject.inject_data proc { {:test => true} }
        subject.instance_variable_get(:@data).should include({:test => true})
      end
    end
  end
  
  describe ".inject_data" do
    it "adds data to the data injects list" do
      subject.class.inject_data({:class_data => true})
      subject.data.should include({:class_data => true})
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
    
    it "gives warning if no setter is found" do
      subject.should_receive(:warn).with(subject.inspect+" did not allow :size to be set to 10.")
      subject.set(:size, 10)
    end
  end
  
  describe "#unset" do
    it "removes a set value" do
      subject.set :output, "test"
      subject.output.should == "test"
      subject.unset :output
      subject.output.should == "txt"
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
    
    it "raises error if argument is not an engine or name" do
      subject.should_receive(:warn).with("5 is not an engine or a registered name for an engine")
      subject.apply(5)
    end
  end
  
  describe "#unapply" do
    before(:all) { @engine = Class.new; Henshin.register_engine(:engine, @engine) }
    subject { Henshin::File.new(nil, nil) { apply(@engine) } }
  
    it "removes an applied engine by class" do
      subject.unapply @engine
      subject.applies.should == []
    end
    
    it "removes an applied engine by symbol" do
      subject.unapply :engine
      subject.applies.should == []
    end
    
    it "raises error if argument is not an engine or name" do
      subject.should_receive(:warn).with("5 is not an engine or a registered name for an engine")
      subject.unapply(5)
    end
  end
  
  describe "#readable?" do    
    it { should be_readable }
  
    it "can be set" do
      subject.set :read, true
      subject.should be_readable
      subject.set :read, false
      subject.should_not be_readable
    end
  end
  
  describe "#renderable?" do
    it { should_not be_renderable }
    
    it "can be set" do
      subject.set :render, true
      subject.should be_renderable
      subject.set :render, false
      subject.should_not be_renderable
    end
  end
  
  describe "#layoutable?" do
    it { should_not be_layoutable }
    
    it "can be set" do
      subject.set :layout, true
      subject.should be_layoutable
      subject.set :layout, false
      subject.should_not be_layoutable
    end
  end
  
  describe "#writeable?" do
    it { should be_writeable }
    
    it "can be set" do
      subject.set :write, true
      subject.should be_writeable
      subject.set :write, false
      subject.should_not be_writeable
    end
  end
  
  describe "#rendered?" do
    context "when file has been rendered" do
      before { subject.render }
      it { should be_rendered }
    end
    
    context "when file has not been rendered" do
      it { should_not be_rendered }
    end
  end
  
  describe "#index?" do
    it "returns true if this is an index file" do
      subject.path = source + 'index.html'
      subject.should be_index
    end
    it "returns false if this isn't an index file" do
      subject.should_not be_index
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
    let(:test_layout) { Henshin::File::Layout.new(source + 'test.liquid', site) }
    let(:default_layout) { Henshin::File::Layout.new(source + 'main.liquid', site) }
    
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
    it "should include values returned by payload_keys" do
      keys = subject.payload_keys.map {|i| i.to_s }
      subject.data.keys.should include(*keys)
    end
    
    it "should include injected data hashes" do
      subject.inject_data({:test => Hash})
      subject.data.should include({:test => Hash})
    end
    
    it "should include injected procs" do
      subject.inject_data { {:test => Proc} }
      subject.data.should include({:test => Proc})
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
      
      it "returns a pretty url if file /something/index.html" do
        subject.stub!(:output).and_return('html')
        subject.path = source + 'folder' + 'index.md'
        subject.url.should == '/folder'
      end
      
      it "returns a pretty url for /index.html" do
        subject.set :output, 'html'
        subject.path = source + 'index.md'
        subject.url.should == '/'
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
    it "returns /index.html for files with url of /" do
      subject.set :url, '/'
      subject.permalink.should == "/index.html"
    end
    
    it "returns the url if it is a permalink" do
      subject.set :url, '/text.html'
      subject.permalink.should == "/text.html"
    end
    
    it "returns the url appended with /index.html if it is pretty" do
      subject.set :url, '/test'
      subject.permalink.should == '/test/index.html'
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
    let(:engine) {
      Class.new(Henshin::Engine) {        
        def render(c, d)
          "#{c} done"
        end
      }
    }
  
    before { 
      subject.set :render, true
      subject.apply(engine) 
    }
  
    context "when not rendered" do
      it "sets #rendered?" do
        subject.render
        subject.should be_rendered
      end
    
      it "runs each engine" do
        engine.should_receive(:render)
        subject.render
      end
      
      it "sets the rendered content" do
        subject.render
        subject.content.should == "Hello I am a test done"
      end
    end
    
    context "when already rendered" do
      before { subject.render }
      
      it "set #rendered?" do
        subject.render
        subject.should be_rendered
      end
    
      it "doesn't run the engines" do
        engine.should_not_receive(:render)
        subject.render
      end
      
      context "when forced" do
        before { subject.render }
      
        it "sets #rendered?" do
          subject.render(true)
          subject.should be_rendered
        end
      
        it "runs each engine" do
          engine.should_receive(:render)
          subject.render(true)
        end
        
        it "sets the rendered content" do
          subject.render(true)
          subject.content.should == "Hello I am a test done"
        end
      end
    end
  end
  
  describe "#layout" do
    context "when passed a layout" do
      it "sets the rendered content" do
        layout = Henshin::File::Layout.new(site.source + 'main.liquid', site)
        layout.should_receive(:render_with).with(subject)
        subject.set :layout, true
        subject.layout(layout)
      end
    end
    
    context "should be settable" do
      it "sets whether the file can use a layout" do
        subject.set :layout, true
        subject.should be_layoutable
        subject.set :layout, false
        subject.should_not be_layoutable
      end
    end
  end
  
  describe "#write" do
    
    # Remove the file that gets written
    after(:all) { FileUtils.rm(site.source + subject.path) }
  
    it "creates the directories" do
      FileUtils.should_receive(:mkdir_p).with (site.source + subject.write_path).dirname
      subject.write(site.source)
    end
    
    it "creates a new file" do
      File.should_receive(:open).with(site.source + subject.write_path, 'w')
      subject.write(site.source)
    end
    
    it "writes the content" do
      File.any_instance.should_receive(:write).with(subject.content)
      subject.write(site.source)
    end
  end

end
