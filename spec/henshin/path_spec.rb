require_relative '../helper'
require 'lib/henshin/path'

describe Henshin::Path do

  subject { Henshin::Path }

  let(:root) { Pathname.new('/') }
  let(:path) { subject.new(root, 'tag', 'code', 'index.html') }

  it 'has an #extension' do
    path.extension.must_equal '.html'
  end

  it 'has a #permalink' do
    path.permalink.must_equal '/tag/code/index.html'
  end

  it 'has a #url' do
    path.url.must_equal '/tag/code/'
  end

  it 'uses strict equality for #==' do
    other = Henshin::Path(root, 'tag', 'code', 'index.html')
    path.must_equal other
  end

  describe '#===' do
    it 'matches permalink' do
      path.must_be :===, '/tag/code/index.html'
    end

    it 'matches url' do
      path.must_be :===, '/tag/code/'
    end

    it 'matches url without trailing slash' do
      path.must_be :===, '/tag/code'
    end

    it 'matches equal Path' do
      other = subject.new(root, 'tag', 'code', 'index.html')
      path.must_be :===, other
    end
  end

  it 'can #<<' do
    path = subject.new(root, 'tag', 'code')
    path << 'test.html'
    path.must_be :===, '/tag/code/test.html'
  end

  it 'defines #Path()' do
    Path(root, 'test').must_equal subject.new(root, 'test')
  end
end
