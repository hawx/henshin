require_relative '../../helper'

describe Henshin::Tag do

  subject     { Henshin::Tag }

  let(:site)  { test_site }
  let(:tests) { test_site.posts.find_all {|p| p.has_tag?('Test') } }
  let(:tag)   { subject.new('Test', site) }

  describe '#posts' do
    it 'filters the correct posts' do
      tag.posts.all? {|p| p.tags.must_include('Test') }
    end
  end

  describe '#basic_data' do
    it 'returns data not dependent on posts' do
      tag.basic_data.must_equal title: 'Test',
                                url: '/tag/test/',
                                permalink: '/tag/test/index.html'
    end
  end

  describe '#data' do
    it 'returns the data' do
      tag.data.must_equal title: 'Test',
                          url: '/tag/test/',
                          permalink: '/tag/test/index.html',
                          posts: tests.map(&:data)
    end
  end

  describe '#text' do
    it 'returns the rendered tag file' do
      tag.text.must_equal "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\" /><link href=\"&#47;style.css\" rel=\"stylesheet\" /><title>Test</title></head><body><a>Home</a><header><h1>#Test</h1></header><ul><li><a href=\"&#47;style-test&#47;\">Style Test</a></li><li><a href=\"&#47;code-testing&#47;\">Code Testing</a></li></ul></body></html>"
    end
  end


  it 'has #permalink' do
    tag.permalink.must_equal '/tag/test/index.html'
  end

  it 'has #url' do
    tag.url.must_equal '/tag/test/'
  end

  describe '#<=>' do
    it 'compares on name' do
      a = subject.new('a', site)
      b = subject.new('b', site)
      a.must_be :<, b
    end
  end

  describe '#writeable?' do
    it 'is true if the template exists' do
      site.expects(:has_template?).returns(true)
      tag.must_be :writeable?
    end

    it 'is false if no template exists' do
      site.expects(:has_template?).returns(false)
      tag.wont_be :writeable?
    end
  end

end
