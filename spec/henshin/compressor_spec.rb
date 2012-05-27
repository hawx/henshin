require_relative '../helper'

describe Henshin::Compressor do

  subject { Henshin::Compressor }

  let(:f1) { stub(:text => "f1") }
  let(:f2) { stub(:text => "f2") }
  let(:f3) { stub(:text => "f3") }

  let(:compressor) { subject.new([f1, f2, f3]) }

  describe '#compress' do
    it 'concatenates the files' do
      compressor.compress.must_equal "f1\nf2\nf3"
    end
  end

end
