require_relative '../../helper'

describe Henshin::File::Physical do

  let(:text) {
    <<EOS
---
title: Test
date:  2012-01-03
---

So, here we are. A test.
EOS
  }

  subject { Henshin::File::Physical }

  let(:site) { DummySite.new(test_path) }
  let(:file) { Henshin::File::Physical.new(site, test_path + 'test.txt') }

  before {
    file.instance_variable_get(:@path).stubs(:read).returns(text)
  }

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
