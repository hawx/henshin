require 'spec_helper'
require 'henshin/engine/liquid' # hmm!!!

describe Henshin::Layout do

  let(:source) { Pathname.new(File.dirname(__FILE__)) + '..' }
  let(:dest)   { source + '_site' }
  let(:site)   { Henshin::Base.new({'dest' => dest, 'source' => source}) }

  subject {
    mock_file Henshin::Layout.new(source + 'main.haml', site), "{{ file.title }} - {{ yield }}"
  }
  
  describe "#name" do
    it "returns a name for the layout" do
      subject.name.should == "main"
    end
  end
  
  describe "#render_with" do
    it "renders the file with the layout" do
      other = mock_file Henshin::File.new(source + 'test.haml', site), <<EOS
---
title: Test File
---

Contents of file
EOS

      subject.apply :liquid
      subject.render_with(other).should == "Test File - Contents of file\n"
    end
  end
  
  it { should be_readable }
  it { should_not be_writeable }
  it { should_not be_renderable }
  it { should_not be_layoutable }

end