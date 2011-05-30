require 'spec_helper'

describe Henshin::Archive do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }
  let(:site)   { 
    Class.new(Henshin::Base) {
      def posts
        self.files.find_all {|i| i.class.name =~ /Post/}
      end
    }.new(config) 
  }

  describe ".create" do
    subject { 
      Class.new(Henshin::Base) {
        Henshin::Archive.create self
      }.new
    }
  
    it "creates archive accessors on class" do
      subject.should respond_to :archive
      subject.should respond_to :archive=
    end
  end
  
  describe ".possible?" do
    subject { Henshin::Archive }
  
    it "returns true if layouts exist" do
      site.files = [
        Henshin::Layout.new(source+'archive.haml', site),
        Henshin::Layout.new(source+'archive_year.haml', site),
        Henshin::Layout.new(source+'archive_month.haml', site),
        Henshin::Layout.new(source+'archive_date.haml', site)
      ]
      subject.possible?(site).should be_true
    end
    it "returns false if layouts do not exist" do
      site.files = []
      subject.possible?(site).should be_false
    end
  end
  
  subject { Henshin::Archive.new(nil, site) }
  
  %w(post1 post2 post3).each do |t|
    let(t.to_sym) { Henshin::Post.new(t+'.txt', site) { set :date, Time.new(2012, 12, 21) } }
  end
  
  describe "#<<" do
    it "adds a post to the correct position in the hash" do
      subject << post1 << post2
      h = subject.instance_variable_get(:@hash)
      h[2012][12][21].should == [post1, post2]
    end
    it "returns nil if post does not respond to #date" do
      s = Henshin::File.new(nil, nil)
      (subject << s).should be_nil
    end
  end
  
  describe "#to_h" do
    it "returns a hash of data" do
      subject << post1 << post2
      subject.to_h.should == {2012 => {12 => {21 => [post1.data, post2.data]}}}
    end
  end
  
  describe "#page_for" do
    it "returns the page for the date given" do
      subject << post1 << post2
      subject.page_for(%w(2012)).should be_kind_of Henshin::Archive::YearPage
      subject.page_for(%w(2012)).url.should == "/2012"
      subject.page_for(%w(2012 12)).should be_kind_of Henshin::Archive::MonthPage
      subject.page_for(%w(2012 12)).url.should == "/2012/12"
      subject.page_for(%w(2012 12 21)).should be_kind_of Henshin::Archive::DatePage
      subject.page_for(%w(2012 12 21)).url.should == "/2012/12/21"
    end
  end
  
  describe "#main_page" do
    it "returns the main page" do
      subject.main_page.should be_kind_of Henshin::Archive::ArchivePage
    end
  end
  
  describe "#pages" do
    it "returns an array of pages" do
      subject << post1
      all_of(subject.pages).should be_kind_of Henshin::Archive::ArchivePage
      subject.pages.map {|i| i.url }.should == %w(/archive /2012 /2012/12 /2012/12/21)
    end
  end

end

describe Henshin::Archive::ArchivePage do
  subject { Henshin::Archive::ArchivePage.new(nil, nil) }
  
  it { should_not be_readable }
  it { should be_layoutable }
  it { should be_renderable }
  it { should be_writeable }
  specify { subject.layout_names.should == ['archive'] }
end

describe Henshin::Archive::YearPage do
  subject { Henshin::Archive::YearPage.new(nil, nil) }
  specify { subject.layout_names.should == ['archive_year'] }
end

describe Henshin::Archive::MonthPage do
  subject { Henshin::Archive::MonthPage.new(nil, nil) }
  specify { subject.layout_names.should == ['archive_month'] }
end

describe Henshin::Archive::DatePage do
  subject { Henshin::Archive::DatePage.new(nil, nil) }
  specify { subject.layout_names.should == ['archive_date'] }
end