require_relative '../helper'

describe Henshin::FileAttributes do

  subject {
    obj = Object.new
    obj.extend Henshin::FileAttributes
    obj
  }

  describe '#requires' do
    it 'adds a required key to the list' do
      subject.requires :apples
      subject.required.must_include :apples
    end
  end

  describe '#required' do
    it 'returns the required keys' do
      subject.requires :apples, :oranges
      subject.required.to_a.must_equal [:apples, :oranges]
    end
  end

end

describe Henshin::AbstractFile do

  let(:subclass) {
    Class.new(Henshin::AbstractFile) {
      def path
        @path ||= Object.new
      end
    }
  }

  let(:site) { test_site }

  subject { subclass.new(site) }

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

  describe '#write' do
    it 'writes the file' do
      writer = mock()
      writer.expects(:write).with(Pathname.new('here'), 'text')

      subject.stubs(:text).returns('text')
      subject.stubs(:permalink).returns('/here')
      Henshin::UI.expects(:wrote).with('/here')

      subject.write writer
    end

    it 'passes time taken to UI if in profile mode' do
      with_profiling! do
        writer = mock()
        writer.expects(:write).with(Pathname.new('here'), 'text')

        Time.stubs(:now).returns(5, 6)

        subject.stubs(:text).returns('text')
        subject.stubs(:permalink).returns('/here')
        Henshin::UI.expects(:wrote).with('/here', 1)

        subject.write writer
      end
    end

    # it 'raises a pretty error if problem occurs' do
    #   writer = mock()
    #   def writer.write(where, what)
    #     raise IOError,'Problems, what did you expect?'
    #   end

    #   proc {
    #     subject.stubs(:permalink).returns(:here)
    #     subject.write(writer)
    #   }.must_output
    # end

    it 'does nothing if not #writeable?' do
      subject.stubs(:writeable?).returns(false)
      writer = mock()
      writer.expects(:write).never

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

  let(:site) { DummySite.new(test_path) }
  let(:file) { Henshin::File.new(site, test_path + 'test.txt') }

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

  describe 'registering new module to apply' do
    it 'is picked up by .create' do
      mod = Module.new
      subject.apply /\.apply/, mod

      file = subject.create(site, Pathname.new('something.apply'))
      file.singleton_class.ancestors.must_include mod
    end
  end

  describe '#method_missing' do
    it 'accesses yaml attributes' do
      file.title.must_equal 'Test'
      file.date.must_equal Date.new(2012, 1, 3)
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

    it 'returns yaml permalink if set' do
      file.stubs(:yaml).returns(permalink: '/cool.permalink')
      file.permalink.must_equal '/cool.permalink'
    end

    it 'removes input file extension if it exists' do
      file = subject.new(site, test_path + 'index.html.slim')
      file.instance_variable_get(:@path).stubs(:read).returns(text)
      file.permalink.must_equal '/index.html'
    end
  end

end
