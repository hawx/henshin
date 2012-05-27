require_relative '../helper'

describe Henshin::Reader do

  subject { Henshin::Reader.new(Pathname.new('site').realpath) }

  def path(path)
    Pathname.new('site').realpath + path
  end

  def paths(*path)
    path.map {|i| path(i) }
  end


  describe '#ignore' do
    it 'adds files to the ignored list' do
      subject.ignore 'crazy-file.txt', 'another?.md'
      subject.must_be :ignore?, path('crazy-file.txt')
    end
  end

  describe '#ignore?' do
    it 'checks if a file is in the ignored list' do
      subject.must_be :ignore?, path('config.yml')
    end

    it 'checks if the file begins with an underscore' do
      subject.must_be :ignore?, path('folder/folder/_file.txt')
    end

    it 'checks if a folder above begins with an underscore' do
      subject.must_be :ignore?, path('folder/_folder/file.txt')
    end
  end

  describe '#read' do
    it 'finds all paths in path given' do
      subject.read('**', '*.sass').must_equal paths('assets/styles/screen.sass')
    end
  end

  describe '#read_all' do
    it 'finds all paths under path given' do
      subject.read_all('assets', 'styles').must_equal paths('assets/styles/screen.sass')
    end
  end

  describe '#safe_paths' do
    it 'finds all paths, excepts from reserved directories' do
      subject.safe_paths.wont_include path('assets/styles/screen.sass')
    end
  end

end
