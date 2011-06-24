require 'spec_helper'

describe Henshin::Base do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }
  
  subject { Henshin::Base.new(config) }
  
  let(:file_txt)  { 
    mock_file Henshin::File::Text.new(source + 'file.txt', subject), 
                'Hello' }
                
  let(:file_sass) { 
    mock_file Henshin::File::Text.new(source + 'file.sass', subject), 
                "body\n  color: red" }
                
  let(:page_md)   { 
    mock_file Henshin::File::Page.new(source + 'page.md', subject), 
                "# Header\ncontent" }
                
  let(:layout)    { 
    mock_file Henshin::File::Layout.new(source + 'layouts/main.liquid', subject) }
    
  let(:files)     { [file_txt, file_sass, page_md, layout] }
  
  
  describe "#config" do
    it "returns merged config with defaults" do
      subject.config.should == Henshin::DEFAULTS.merge(config)
    end
  end
  
  describe "#source" do
    it "returns the read directory" do
      subject.source.should == source
    end
  end
  
  describe "#dest" do
    it "returns the write directory" do
      subject.dest.should == dest
    end
  end
  
  describe "#server?" do
    context "when server has been set to be running" do
      before { subject.server = true }
      it { should be_server }
    end
    
    context "by default" do
      it { should_not be_server }
    end
  end
  
  describe "#load_config" do
    it "calls load config on it's class with source directory" do
      subject.class.should_receive(:load_config).with([subject.source, Pathname.pwd])
      subject.load_config
    end
  end
  
  describe ".load_config" do
    before {
      @path = mock('path')
      @path.stub(:+).and_return(@path)
      @path.stub(:exist?).and_return(true)
    }
  
    it "loads the config.yml"do
      YAML.stub!(:load_file).with(@path).and_return({'loaded' => true})
      Henshin::Base.load_config([@path]).should == {'loaded' => true}
    end
  
    it "converts dest and source to pathname objects" do
      YAML.stub!(:load_file).with(@path).and_return({'source' => 'path', 'dest' => 'path'})
      l = Henshin::Base.load_config([@path])
      l['source'].should be_kind_of Pathname
      l['dest'].should be_kind_of Pathname
    end
  end
  
  describe "#load_files" do
    it "loads files"
    it "evaluates the files in the current class"
    it "ignores the files so it isn't read"
  end
  
  describe "#ignores?" do
    it "returns true for ignores files" do
      subject.ignore 'about.md'
      subject.ignores?(source + 'file.txt').should be_false
      subject.ignores?(source + 'about.md').should be_true
      subject.class.ignores = []
    end
    
    it "it returns true for files specified in config" do
      subject.config['ignore'] << 'about.liquid'
      subject.ignores?(source + 'file.txt').should be_false
      subject.ignores?(source + 'about.liquid').should be_true
    end
  end
  
  describe "#read" do
    it "reads the files from the directories given" do
      all_of(subject.read.map {|i| i.path.to_s }).should match /#{source.to_s}/
    end
    
    it "removes directories" do
      all_of(subject.read.map(&:path)).should_not be_directory
    end
    
    it "removes ignored files" do
      subject.ignore 'about.liquid'
      all_of(subject.read.map {|i| i.path.to_s }).should_not match /about\.liquid/
      subject.class.ignores = []
    end
    
    it "creates instances of correct classes using filters" do
      subject.filter 'layouts/*.*', Henshin::File::Layout, :internal
      files = subject.read
      files.find {|i| i.relative_path.to_s == "layouts/main.liquid" }.should be_kind_of Henshin::File::Layout
      files.find {|i| i.relative_path.to_s == "layouts/plain.liquid" }.should be_kind_of Henshin::File::Layout
    end
    
    context "for files that don't match any filters" do
      it "creates binary files if file is binary" do
        files = subject.read
        files.find {|i| i.relative_path.to_s == "audio.mp3"}.should be_kind_of Henshin::File::Binary
        files.find {|i| i.relative_path.to_s == "image.png"}.should be_kind_of Henshin::File::Binary
      end
      
      it "creates text files for all others" do
        files = subject.read
        files.find {|i| i.relative_path.to_s == "index.liquid" }.should be_kind_of Henshin::File::Text
        # files.find {|i| i.relative_path.to_s == "about.liquid" }.should be_kind_of Henshin::File::Text
      end
    end
  end
  
  describe "#layouts" do
    before { subject.files = files }
    it "returns all files which are a Layout" do
      subject.layouts.should == [layout]
    end
  end
  
  describe "#pre_render" do
    it "calls #pre_render_file on each file" do
      files = subject.read
      files.each do |i|
        subject.should_receive(:pre_render_file).with(i)
      end
      subject.pre_render(files)
    end
  end
  
  describe "#pre_render_file" do
    before { subject.class.rules = [] }
  
    it "runs matching blocks" do
      subject.rule('*.txt') { puts 'yes' }
      subject.rule('*.md')  { puts 'no' }
      $stdout.should_receive(:puts).with('yes')
      $stdout.should_not_receive(:puts).with('no')
      subject.pre_render_file(file_txt)
    end
    
    it "defines splat method on file for length of block" do
      subject.rule('*.*') { puts splat }
      $stdout.should_receive(:puts).with(["file", "txt"])
      subject.pre_render_file(file_txt)
      file_txt.should_not respond_to :splat
    end
    
    it "defines keys method on file" do
      subject.rule(':name.:ext') { puts keys }
      $stdout.should_receive(:puts).with({'name' => 'file', 'ext' => 'txt'})
      subject.pre_render_file(file_txt)
      file_txt.should_not respond_to :keys
    end
    
    it "executes the block within the file" do
      subject.rule('*.*') { puts self.class }
      $stdout.should_receive(:puts).with(Henshin::File::Text)
      subject.pre_render_file(file_txt)
    end
  end
  
  describe "#render" do
    it "calls #render_file on each file" do
      files = subject.read
      files.each do |i|
        subject.should_receive(:render_file).with(i, false)
      end
      subject.render(files)
    end
  end
  
  describe "#render_file" do
    before {
      file_txt.stub!(:render)
      file_txt.stub!(:find_layout).and_return(layout)
      layout.stub!(:render_with)
    }
  
    it "calls #render on the file" do
      file_txt.should_receive(:render).with(false)
      subject.render_file(file_txt)
    end
    
    it "calls #layout on the file" do
      file_txt.should_receive(:layout)
      subject.render_file(file_txt)
    end
  end
  
  describe "#write" do
    it "calls #write_file for each file" do
      files.each {|i|
        i.stub!(:write)
        subject.should_receive(:write_file).with(i)
      }
      subject.write(files)
    end
  end
  
  describe "#write_file" do
    it "calls the file's write method with the write path" do
      file_txt.should_receive(:write).with(subject.dest)
      subject.write_file(file_txt)
    end
  end

  describe "#payload" do
    it "merges the config" do
      subject.payload['site'].should include config
    end
    
    it "has keys for each file key" do
      subject.files = files
      subject.payload.keys.should include 'files', 'pages'
    end
    
    it "merges injects" do
      hash = {'test' => {'one' => 1}}
      subject.inject_payload(hash)
      subject.payload.should include hash
    end
  end
  
  describe "#inject_payload" do
    it "adds a hash to the injects list" do
      hash = {'test' => {'one' => 1}}
      subject.inject_payload(hash)
      subject.injects.should include hash
    end
  end
  
# The DSL
  
  describe ".rule" do
    it "adds a rule" do
      proc = lambda {|f| puts 'hi' }
      subject.class.rule('file', &proc)
      subject.rules.map {|i| [i[0].to_s, i[1]]}.should include ['file', proc]
    end
  end
  
  describe ".filter" do
    it "adds a filter block" do
      subject.class.filter('file', Henshin, :medium)
      subject.filter_blocks.map {|i| i.map(&:to_s)}
        .should include ['file', 'Henshin', '1']
    end
  end
  
  describe ".ignore" do
    it "adds the pattern to ignores list" do
      subject.class.ignore('somepath', 'another')
      subject.ignores.map(&:to_s).should include 'somepath', 'another'
    end
  end
  
  describe ".set" do
    it "sets a pre_config value" do
      subject.class.set :a, 'b'
      subject.class.pre_config['a'].should == 'b'
    end
  end
  
  describe ".resolve" do
    it "sets a routing file" do
      subject.class.resolve(/xyz/, 'file')
      subject.routes.to_a[0][0].regex.should == /xyz/
      subject.routes.to_a[0][1].should == 'file'
    end
    
    it "sets a routing block" do
      proc = lambda { puts 'hi' }
      subject.class.resolve(/xyz/, &proc)
      subject.routes.to_a[1][0].regex.should == /xyz/
      subject.routes.to_a[1][1].should == proc
    end
  end
  
  %w(before after before_each after_each).each do |t|
    describe ".#{t}" do
      it "sets a #{t} block" do
        proc = lambda { puts "hi" }
        subject.class.send(t, :render, &proc)
        subject.actions[t.to_sym][:render].should include proc
      end
    end
  end
  
  describe "#run" do
    before { subject.class.after(:write) { $stdout.puts("hi") } }
    it "runs the relevant block" do
      $stdout.should_receive(:puts).with("hi")
      subject.run(:after, :write)
    end
  end
  
end