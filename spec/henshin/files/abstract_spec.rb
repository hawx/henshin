require_relative '../../helper'

describe Henshin::File::Abstract do

  let(:subclass) {
    Class.new(Henshin::File::Abstract) {
      def path
        @path ||= Object.new
      end
    }
  }

  let(:site) { test_site }

  subject { subclass.new(site) }


  describe '#site' do
    it 'can not be written' do
      subject.site.write(Object.new).must_equal nil
    end
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

  describe '#write' do
    it 'writes the file' do
      writer = mock { expects(:write).with(Pathname.new('here'), 'text') }

      subject.stubs(:text).returns('text')
      subject.stubs(:permalink).returns('/here')
      Henshin::UI.expects(:wrote).with('/here')

      subject.write writer
    end

    it 'passes time taken to UI if in profile mode' do
      with_profiling! do
        writer = mock { expects(:write).with(Pathname.new('here'), 'text') }

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
      writer = mock { expects(:write).never }

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
