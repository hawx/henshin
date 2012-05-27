require_relative '../helper'

describe Henshin::AbstractFile do

  let(:subclass) {
    Class.new(Henshin::AbstractFile) {
      def path; @path ||= Object.new; end
    }
  }

  subject { subclass.new }

  it 'returns a Hash for #data' do
    subject.data.must_be_kind_of Hash
  end

  it 'returns a String for #text' do
    subject.text.must_be_kind_of String
  end

  it 'has a #permalink' do
    subject.path.expects(:permalink).returns('here')
    subject.permalink.must_equal 'here'
  end

  it 'has a #url' do
    subject.path.expects(:url).returns('here')
    subject.url.must_equal 'here'
  end

  it 'has an #extension' do
    subject.path.expects(:extension).returns('.txt')
    subject.extension.must_equal '.txt'
  end

  it 'is #writeable?' do
    subject.must_be :writeable?
  end

  describe '#write' do
    it 'writes the file' do
      writer = mock()
      writer.expects(:write).with(Pathname.new('here'), 'text')

      subject.stubs(:text).returns('text')
      subject.stubs(:permalink).returns('/here')
      Henshin::UI.expects(:wrote).with('/here')

      subject.write writer
    end
  end

  describe '#<=>' do
    it 'compares permalinks' do
      a = subject.dup
      a.stubs(:permalink).returns('a')
      b = subject.dup
      b.stubs(:permalink).returns('b')
      a.must_be :<=>, b, -1
    end
  end

end


describe Henshin::File do

  let(:text) {
    <<EOS
---
title: Test
date:  2012-01-03
---

So, here we are. A test.
EOS
  }

  subject { Henshin::File }

  let(:site) { DummySite.new('.') }
  let(:file) { Henshin::File.new(site, Pathname.new('test.txt')) }

  before {
    file.instance_variable_get(:@path).stubs(:read).returns(text)
  }

  describe 'registering new file type' do
    it 'is picked up by .create' do
      klass = Class.new(subject)
      subject.register /\.test/, klass

      file = subject.create(site, Pathname.new('something.test'))
      file.class.must_equal klass
    end
  end

  describe '#read' do
    it 'returns the yaml part' do
      file.read[0].must_equal "title: Test\ndate:  2012-01-03"
    end

    it 'returns the text part' do
      file.read[1].must_equal "\nSo, here we are. A test.\n"
    end
  end

  describe '#yaml' do
    it 'returns the parsed yaml' do
      file.yaml.must_equal title: 'Test',
                           date: Date.new(2012, 1, 3)
    end
  end

  describe '#data' do
    it 'returns data for the file' do
      file.data.must_equal title: 'Test',
                           date: Date.new(2012, 1, 3),
                           url: '/test.txt',
                           permalink: '/test.txt'
    end
  end

  describe '#text' do
    it 'returns the text' do
      file.text.must_equal "\nSo, here we are. A test.\n"
    end
  end

  describe '#permalink' do
    it 'returns the permalink' do
      file.permalink.must_equal '/test.txt'
    end
  end

end
