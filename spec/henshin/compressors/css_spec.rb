require_relative '../../helper'

describe Henshin::Compressor::Css do

  subject { Henshin::Compressor::Css }

  before { YUI::CssCompressor.stubs(:new).returns(yui) }

  let(:f1) { stub(:text => "f1") }
  let(:f2) { stub(:text => "f2") }
  let(:f3) { stub(:text => "f3") }

  let(:compressor) { subject.new([f1, f2, f3]) }
  let(:yui)        { mock(:compress => "f1\nf2\nf3") }

  describe '#compress' do
    it 'concatenates the files' do
      compressor.compress
    end
  end

end
