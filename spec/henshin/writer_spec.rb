require_relative '../helper'

describe Henshin::Writer do

  subject { Henshin::Writer }

  describe '#dry_run!' do
    it 'stops Writer writing files' do
      subject.dry_run!

      subject.expects(:write_dir).never
      subject.expects(:write_file).never

      subject.write Pathname.new('build/test.txt'), 'Hello!'
    end
  end

  describe '#write' do
    it 'writes the files' do
      subject.real!

      path = Pathname.new('build/test.txt')
      FileUtils.expects(:mkdir_p)
      File.expects(:open).with(path, 'w')

      subject.write Pathname.new('build/test.txt'), 'Hello!'
    end
  end
end
