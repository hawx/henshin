require_relative '../helper'

describe Henshin::Site do

  let(:site) { test_site }

  describe '#url_root' do
    it 'uses root from config' do
      site.stubs(:config).returns(:root => 'cool/path/')
      site.url_root.must_equal Pathname.new('/cool/path/')
    end

    it 'returns / by default' do
      site.url_root.must_equal Pathname.new('/')
    end
  end

  describe '#config' do
    it 'returns the loaded config'
  end

  describe '#data' do
    it 'returns all the data'
  end

  describe '#tags' do
    it 'returns the tags'
  end

  describe '#style' do
    it 'returns the style package'
  end

  describe '#script' do
    it 'returns the script package'
  end

  describe '#posts' do
    it 'returns the posts'
  end

  describe '#templates' do
    it 'returns the templates'
  end

  describe '#files' do
    it 'returns the files'
  end

  describe '#all_files' do
    it 'return all the files'
  end

  describe '#template' do
    it 'returns the first matching template'
    it 'tries to return the default template'
  end

  describe '#template' do
    it 'returns the first matching template'
    it 'returns the empty template if no match'
  end

  describe '#write' do
    it 'writes all the files'
  end

end
