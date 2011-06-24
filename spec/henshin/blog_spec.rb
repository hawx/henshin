require 'spec_helper'

describe Henshin::Blog do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }
  
  let(:site) { Henshin::Blog.new(config) }
  subject { Henshin::Blog.new(config) }
  
  let(:file)   { mock_file Henshin::File.new(source + 'file.txt', subject) }
  let(:page)   { mock_file Henshin::File::Page.new(source + 'page.md', subject) }     
  let(:layout) { mock_file Henshin::File::Layout.new(source + 'layouts/main.liquid', subject) }
  let(:post1)  { mock_file Henshin::File::Post.new(source + 'post1.md', subject) }
  let(:post2)  { mock_file Henshin::File::Post.new(source + 'post2.md', subject) }
  
  
  
  
  describe "#posts" do
    before { subject.files << file << page << layout << post1 << post2 }
    it "returns all posts" do
      subject.posts.should == [post1, post2]
    end
  end
  
  it { should ignore '_site/index.html' }
  it { should ignore 'config.yml' }
  
  describe "rules" do
  
    context "for plain posts" do
      subject  { mock_file Henshin::File::Post.new(source + 'posts/post.md', site) }
      
      it { should have_set_title_to 'post' }
      it { should have_applied :maruku }
    end
    
    context "for posts with categories" do
      subject { mock_file Henshin::File::Post.new(source + 'posts/tech/ipad.textile', site) }
      
      it { should have_set_title_to 'ipad' }
      it { should have_set_category_to 'tech' }
      it { should have_applied :redcloth }
    end
  
    context "for posts with date" do
      subject { mock_file Henshin::File::Post.new(source + 'posts/2011/05/01/dated.haml', site) }
    
      it { should have_set_title_to 'dated' }
      it { should have_set_date_to Time.new(2011, 5, 1) }
      it { should have_applied :haml }
    end
    
  end
  
end