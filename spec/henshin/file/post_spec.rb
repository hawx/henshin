require 'spec_helper'

describe Henshin::Post do

  subject {
    mock_file Henshin::Post.new('a-post.md', nil), "---\n
title: A Post\n
date: 2012-12-21 06:45\n
---\n
\n
Here is a post.\n" }

  describe "#date" do
    it "returns the date the post was written on" do
      subject.date.should == Time.new(2012, 12, 21, 6, 45)
    end
  end
  
  describe "#url" do
    it "returns a url with the date in it" do
      subject.url.should == "/2012/12/21/a-post"
    end
  end
  
  describe "#title" do
    it "gets the title from the yaml" do
      subject.title.should == "A Post"
    end
  end
  
  describe "#permalink" do
    it "returns the permalink" do
      subject.permalink == "/2012/12/21/a-post/index.html"
    end
  end
  
  describe "#key" do
    specify { subject.key.should == :post }
  end
  
  describe "#output" do
    specify { subject.output.should == 'html' }
  end
  
  describe "#<=>" do
    let(:a) {
      mock_file Henshin::Post.new('a', nil) { set :date, Time.new(2012, 12, 21, 6, 44) }, ''
    }
      
    let(:s) { mock_file Henshin::Post.new('what-post.md', nil), "---\n
title: Two Posts\n
date: 2012-12-21 06:45\n
---\n
\n
Hey.\n"}
      
    # subject
    let(:b) {
      mock_file Henshin::Post.new('b', nil) { set :date, Time.new(2012, 12, 21, 6, 46) }, ''
    }
  
    it "compares by date" do
      (a <=> b).should == -1
    end
    
    it "compares by permalink if dates are equal" do
      (s <=> subject).should == 1
    end
  end
  
  describe "#next" do
    it "returns the post with the next date after this"
  end
  
  describe "#previous" do
    it "returns the post before this"
  end

end