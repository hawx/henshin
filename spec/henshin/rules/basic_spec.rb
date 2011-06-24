require 'spec_helper'

describe Henshin::Rules::Basic do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' + 'test_site' }
  let(:dest)   { source + '_site' }
  let(:config) { {'source' => source, 'dest' => dest} }
  
  let(:site) { Henshin::Blog.new(config) }
  
  def file_for(ext)
    Henshin::File.new("file.#{ext}", site)
  end


  context "for liquid files" do
    subject { file_for 'liquid' }
    
    it { should have_applied :liquid }
  end
  
  context "for markdown files" do
    subject { file_for 'md' }
    
    context "by default" do
      it { should have_applied :maruku }
    end
    context "when markdown engine set to kramdown" do
      before { subject.instance_variable_get(:@site).set :markdown, 'kramdown' }
      it { should have_applied :kramdown }
    end
    context "when markdown engine set to maruku" do
      before { subject.instance_variable_get(:@site).set :markdown, 'maruku' }
      it { should have_applied :maruku }
    end
    context "when markdown engine set to rdiscount" do
      before { subject.instance_variable_get(:@site).set :markdown, 'rdiscount' }
      it { should have_applied :rdiscount }
    end
  end
  
  context "for erb files" do
    subject { file_for 'erb' }
    it { should have_applied :erb }
  end
  
  context "for haml files" do
    subject { file_for 'textile' }
    it { should have_applied :redcloth }
  end
  
  context "for rdoc files" do
    subject { file_for 'rdoc' }
    it { should have_applied :rdoc }
  end
  
  context "for builder files" do
    subject { file_for 'builder' }
    it { should have_applied :builder }
    it { should have_set_output_to 'xml' }
    it { should have_set_layout_to false }
  end
  
  context "for nokogiri files" do
    subject { file_for 'nokogiri' }
    it { should have_applied :nokogiri }
    it { should have_set_output_to 'xml' }
    it { should have_set_layout_to false }
  end

  context "for sass files" do
    subject { file_for 'sass' }
    it { should have_applied :sass }
    it { should have_set_output_to 'css' }
    it { should have_set_layout_to false }
  end
  
  context "for scss files" do
    subject { file_for 'scss' }
    it { should have_applied :scss }
    it { should have_set_output_to 'css' }
    it { should have_set_layout_to false }
  end
  
  context "for coffeescript files" do
    subject { file_for 'coffee' }
    it { should have_applied :coffeescript }
    it { should have_set_output_to 'js' }
    it { should have_set_layout_to false }
  end
end