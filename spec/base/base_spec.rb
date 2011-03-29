require 'spec_helper'

describe Henshin::Base do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }

  subject { Henshin::Base.new(config) }
  
  let(:file_txt)  { mock_file Henshin::File.new(source + 'file.txt', subject), 'Hello' }
  let(:file_sass) { mock_file Henshin::File.new(source + 'file.sass', subject), "body\n  color: red" }
  let(:page_md)   { mock_file Henshin::Page.new(source + 'page.md', subject), "# Header\ncontent" }
  let(:layout)    { mock_file Henshin::Layout.new(source + 'layouts/main.liquid', subject) }
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
  
  describe "#layout_paths" do
    it "returns the paths to search for layouts" do
      subject.layout_paths.should == Henshin::DEFAULTS['layout_paths']
    end
  end
  
  describe "#load_config" do
    before {
      YAML.stub!(:load_file).and_return({'loaded' => true})
    }
    
    it "does something"
  end
  
  describe ".load_config" do
    it "calls #load_config on a new instance of Base"
  end
  
  describe "#read" do
    it "reads the files from the directories given"
    it "removes directories"
    it "removes ignored files"
    it "creates instances of correct classes"
  end
  
  describe "#layouts" do
    before { subject.files = files }
    it "returns all files which are a Layout" do
      subject.layouts.should == [layout]
    end
  end
  
  describe "#pre_render" do
    it "calls #pre_render_file on each file"
  end
  
  describe "#pre_render_file" do
    it "runs matching blocks"
    it "defines splat method on file"
    it "defines keys method on file"
    it "executes the block within the file"
  end
  
  describe "#render" do
    it "calls #render_file on each file"
  end
  
  describe "#render_file" do
  
    before {
      file_txt.stub!(:render)
      file_txt.stub!(:find_layout).and_return(layout)
      layout.stub!(:render_with)
    }
  
    it "calls the file render method" do
      file_txt.should_receive(:render)
      subject.render_file(file_txt)
    end
    
    it "renders the file with the correct layout" do
      file_txt.stub!(:find_layout).and_return(layout)
      layout.should_receive(:render_with).with(file_txt)
      subject.render_file(file_txt)
    end
    
    it "sets the file's rendered content" do
      layout.stub!(:render_with).and_return("Rendered")
      subject.render_file(file_txt)
      file_txt.content.should == "Rendered"
    end
  end
  
  describe "#write_path" do
    specify { subject.write_path.should be_kind_of Pathname }
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
      file_txt.should_receive(:write).with(subject.write_path)
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
  
  describe ".render" do
    it "adds a render block" do
      proc = lambda {|f| puts 'hi' }
      subject.class.render('file', &proc)
      subject.render_blocks.map {|i| [i[0].to_s, i[1]]}.
        should include ['file', proc]
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
  
  {'pre_config' => 'set', 'constant' => 'const'}.each do |getter, setter|
    describe ".#{setter}" do
      it "sets a #{getter} value" do
        subject.class.send(setter.to_sym, :a, 'b')
        subject.send(getter)['a'].should == 'b'
      end
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