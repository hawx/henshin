require 'spec_helper'

describe Henshin::Blog do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }
  
  subject { Henshin::Blog.new(config) }
  
  let(:file)   { mock_file Henshin::File.new(source + 'file.txt', subject) }
  let(:page)   { mock_file Henshin::Page.new(source + 'page.md', subject) }     
  let(:layout) { mock_file Henshin::Layout.new(source + 'layouts/main.liquid', subject) }
  let(:post1)  { mock_file Henshin::Post.new(source + 'post1.md', subject) }
  let(:post2)  { mock_file Henshin::Post.new(source + 'post2.md', subject) }
  
  describe "#posts" do
    before { subject.files << file << page << layout << post1 << post2 }
    it "returns all posts" do
      subject.posts.should == [post1, post2]
    end
  end
  
end