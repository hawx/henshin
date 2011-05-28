require 'spec_helper'

describe Henshin::Post do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }
  let(:site)   { Henshin::Blog.new(config) }
    
  let(:first_post) { 
    mock_file Henshin::Post.new(source + 'alphabetically-first.md', site) {
      set :date, Time.new(2012, 12, 21, 6, 45)
    }
  }
  
  subject {
    mock_file Henshin::Post.new(source + 'the-subject.md', site) {
      set :date, Time.new(2012, 12, 21, 6, 45)
      set :title, "The Subject"
    }
  }
    
  let(:last_post) {
    mock_file Henshin::Post.new(source + 'time-wise-last.md', site) { 
      set :date, Time.new(2012, 12, 21, 6, 46) 
    }
  }
  
  before { site.files += [subject, first_post, last_post] }

  describe "#date" do
    it "returns the date the post was written on" do
      subject.date.should == Time.new(2012, 12, 21, 6, 45)
    end
  end
  
  describe "#url" do
    it "returns a url with the date in it" do
      subject.url.should == "/2012/12/21/the-subject"
    end
  end
  
  describe "#title" do
    it "gets the title from the yaml" do
      subject.title.should == "The Subject"
    end
  end
  
  describe "#permalink" do
    it "returns the permalink" do
      subject.permalink.should == "/2012/12/21/the-subject/index.html"
    end
  end
  
  describe "#write_path" do
    it "returns the permalink as a relative pathname" do
      subject.write_path.to_s.should == '2012/12/21/the-subject/index.html'
    end
  end
  
  describe "#key" do
    specify { subject.key.should == :post }
  end
  
  describe "#output" do
    specify { subject.output.should == 'html' }
  end
  
  describe "#<=>" do
    it "compares by date" do
      (subject <=> last_post).should == -1
    end
    
    it "compares by permalink if dates are equal" do
      (subject <=> first_post).should == 1
    end
  end
  
  describe "#next" do 
    it "returns the post with the next date after this" do
      subject.next.should == last_post
    end
  end
  
  describe "#previous" do
    it "returns the post before this" do
      subject.previous.should == first_post
    end
  end

end