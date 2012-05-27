require_relative '../../helper'

describe Henshin::Post do

  let(:text) {
    <<EOS
---
title: Hello World
date:  2012-01-03
tag:   Test
---

So, a post. Finally?
EOS
  }

  let(:site) { test_site }

  subject { Henshin::Post }
  let(:post) {
    file = Henshin::File.new(site, Pathname.new('posts/1-hello-world.md'))
    file.extend subject
    file
  }

  before {
    post.instance_variable_get(:@path).stubs(:read).returns(text)
  }

  describe '#text' do
    it 'returns the text, rendered, templated' do
      site.expects(:template).returns("Hello")
      post.text.must_equal "Hello"
    end
  end

  describe '#data' do
    it 'returns the data' do
      post.data.must_equal title: 'Hello World',
                           date: Date.new(2012, 1, 3),
                           url: '/hello-world/',
                           permalink: '/hello-world/index.html',
                           tags: []
    end
  end

  describe '#permalink' do
    it 'returns the permalink' do
      post.permalink.must_equal '/hello-world/index.html'
    end
  end

end
