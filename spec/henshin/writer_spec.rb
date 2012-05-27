require_relative '../helper'

describe Henshin::Writer do

  subject { Henshin::Writer.new(Pathname.new('build')) }


  describe '#write' do
    it 'does nothing when dry run' do
      subject.expects(:write_dir).never
      subject.expects(:write_file).never

      subject.write Pathname.new('test.txt'), 'Hello!'
    end

    it 'writes the contents to the path' do
      with_writing! do
        obj = Object.new
        FileUtils.expects(:mkdir_p)
        File.expects(:open).with('build/test.txt', 'w')

        subject.write Pathname.new('test.txt'), 'Hello!'
      end
    end
  end
end
