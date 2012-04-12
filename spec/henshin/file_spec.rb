require_relative '../helper'

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

  let(:site) { Henshin::Site.new('.') }
  let(:file) { Henshin::File.new(site, 'test.txt') }

  before {
    Henshin::Writer.dry_run!
    file.path.stubs(:read).returns(text)
  }

  describe '#initialize' do
    it 'makes sure path is a Pathname' do
      file.path.must_be_kind_of Pathname
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

  describe '#data' do
    it 'returns data for the file' do
      file.data.must_equal title: 'Test',
                           date: Date.new(2012, 1, 3),
                           url: '/test.txt',
                           permalink: '/test.txt',
                           mime: 'text/plain'
    end
  end

  describe '#mime' do
    it 'returns the correct mime type' do
      file.mime.must_equal 'text/plain'
    end
  end

  describe '#text' do
    it 'returns the text' do
      file.text.must_equal "\nSo, here we are. A test.\n"
    end
  end

  describe '#url' do
    it 'returns the url' do
      file.url.must_equal '/test.txt'
    end
  end

  describe '#permalink' do
    it 'returns the permalink' do
      file.permalink.must_equal '/test.txt'
    end
  end

  describe '#extension' do
    it 'returns the extension of the written file' do
      file.extension.must_equal '.txt'
    end
  end

  describe '#write' do
    it 'writes the file' do
      file.stubs(:write_path).returns('build/test.txt')
      Henshin::Writer.expects(:write).with('build/test.txt',
                                           "\nSo, here we are. A test.\n")
      Henshin::UI.expects(:wrote).with('test.txt')
      file.write('build')
    end
  end

end
