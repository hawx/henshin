require 'spec_helper'

describe Henshin::Labels do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }
  let(:site)   { 
    Class.new(Henshin::Base) {
      def posts
        self.files.find_all {|i| i.class == Henshin::File::Post }
      end
    }.new(config) 
  }

  describe ".define" do
    subject {
      Class.new(Henshin::Base) {
        Henshin::Labels.define :label, :labels, self
      }.new
    }
  
    it "creates accessor methods" do
      subject.should respond_to :labels
      subject.should respond_to :labels=
    end
  end
  
  describe ".possible?" do
    subject { Henshin::Labels }
  
    it "returns true if layouts exists" do
      site.files = [
        Henshin::File::Layout.new(source+'tag_index.haml', site),
        Henshin::File::Layout.new(source+'tag_page.haml', site)
      ]
      subject.possible?(:tag, site).should == true
    end
    it "returns false if layouts do not exist" do
      site.files = []
      subject.possible?(:tag, site).should == false
    end
  end
  
  subject { Henshin::Labels.create(:label, :labels, site) }
  
  %w(test1 test2 test3).each do |t|
    let(t.to_sym) { Henshin::Label.define(:label, :labels, t, site) }
  end

  describe ".create" do
    it "sets singular name" do
      subject.single.should == :label
    end
    it "sets plural name" do
      subject.plural.should == :labels
    end
    it "returns a labels instance" do
      subject.should be_kind_of Henshin::Labels
    end
  end
  
  describe "#<<" do
    it "adds the item to the list" do
      subject << 1
      subject.list.should == [1]
    end
    
    it "doesn't add if already present in list" do
      subject << 1
      subject << 1
      subject.list.should == [1]
    end
  end
  
  describe "#[]" do
    it "finds items by #name" do
      subject << test1 << test2 << test3
      subject['test2'].should == test2
    end
  end
  
  describe "#add_for" do
    it "adds the item to the label given's list" do
      subject << test1
      subject.add_for('test1', "new")
      subject['test1'].list.should == ["new"]
    end
  end
  
  describe "#create_or_find" do
    before { subject << test1 << test2 << test3 }
  
    it "finds the label by name if it exists" do
      subject.create_or_find('test2').should == test2
    end
    
    it "creates the label if it doesn't exist" do
      r = subject.create_or_find('test4')
      r.should be_kind_of Henshin::Label
      r.name.should == 'test4'
    end
  end
  
  describe "#items_for" do
    it "returns the data for a single post across all defined labels" do
      subject << test1
      post = mock_file(Henshin::File::Post.new('what', site))
      subject.add_for('test1', post)
      subject.items_for(post).should == [test1]
    end
  end
  
  it { should_not be_readable }
  it { should be_renderable }
  it { should be_layoutable }
  it { should be_writeable }
  
  describe "#key" do
    it "returns the plural name" do
      subject.key.should == :labels
    end
  end
end

describe Henshin::Label do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }
  let(:site)   { 
    Class.new(Henshin::Base) {
      def posts
        self.files.find_all {|i| i.class == Henshin::File::Post }
      end
    }.new(config) 
  }  
  
  subject { Henshin::Label.define(:label, :labels, 'software', site) }
  
  describe ".define" do  
    it "sets the singular name" do
      subject.single.should == :label
    end
    it "sets the plural name" do
      subject.plural.should == :labels
    end
    it "sets the name of the label" do
      subject.name.should == 'software'
    end
    it "returns a label instance" do
      subject.should be_kind_of Henshin::Label
    end
  end
  
  describe "#path" do
    it "returns path with name and correct extension" do
      subject.path.to_s.should == (source + 'labels' + 'software.html').to_s
    end
  end
  
  describe "#posts" do
    let(:post) { mock_file(Henshin::File::Post.new("what.txt", site)) }
    before { subject.list << post }
  
    it "returns an array of posts data for the label" do
      subject.posts.should == [post.data]
    end
  end
  
  describe "#url" do
    it "returns a url with the plural name and the label's name" do
      subject.url.should == "/labels/software"
    end
  end
  
  describe "#key" do
    it "returns the singular name" do
      subject.key.should == :label
    end
  end
  
  it { should_not be_readable }
  it { should be_renderable }
  it { should be_layoutable }
  it { should be_writeable }
  
  describe "#layout_names" do
    it "returns an array with the layout name" do
      subject.layout_names.should == ["label_page"]
    end
  end

end