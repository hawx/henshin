require_relative '../../helper'

describe Henshin::CssCompressor do

  subject { Henshin::CssCompressor }

  let(:yui) { mock() }
  before { YUI::CssCompressor.stubs(:new).returns(yui) }

  let(:f1) { stub(:text => "f1") }
  let(:f2) { stub(:text => "f2") }
  let(:f3) { stub(:text => "f3") }

  let(:compressor) { subject.new([f1, f2, f3]) }

  describe '#compress' do
    it 'concatenates the files' do
      yui.expects(:compress).with("f1\nf2\nf3")
      compressor.compress
    end
  end

end
