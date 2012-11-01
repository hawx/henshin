require_relative '../helper'

describe Henshin::Compressor do

  subject { Henshin::Compressor }

  let(:f1) { stub(:text => "f1") }
  let(:f2) { stub(:text => "f2") }
  let(:f3) { stub(:text => "f3") }

  let(:compressor) { subject.new([f1, f2, f3]) }

  describe '#join' do
    it 'joins the contents of the files together' do
      compressor.join.must_equal "f1\nf2\nf3"
    end
  end

  describe '#compress' do
    it 'calls #join' do
      compressor.compress.must_equal "f1\nf2\nf3"
    end
  end

end
