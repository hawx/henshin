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
      post.text.must_equal "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\" /><link href=\"&#47;style.css\" rel=\"stylesheet\" /><title>Hello World</title></head><body onload=\"window.scrollBy(0,54);\"><nav><a class=\"home\" href=\"&#47;\">Home</a></nav><header><h1>Hello World</h1></header>
So, a post. Finally?
<div class=\"meta\"><span class=\"date\">&mdash;  </span></div><script src=\"http://alexgorbatchev.com/pub/sh/current/scripts/shCore.js\"></script><script src=\"http://alexgorbatchev.com/pub/sh/current/scripts/shAutoloader.js\"></script><script src=\"&#47;script.js\"></script></body></html>"
    end
  end

  it 'returns date suitable for rss with #rss_date' do
    post.rss_date.must_equal "Tue, 3 Jan 2012 00:00:00 +0000"
  end

  describe 'next post' do
    let(:n) { Object.new }

    it 'can set and get next post' do
      post.next = n
      post.next_post.must_equal n
    end
  end

  describe 'prev post' do
    let(:p) { Object.new }

    it 'can set and get previous post' do
      post.prev = p
      post.prev_post.must_equal p
    end
  end

  describe '#path' do
    it 'returns the path' do
      post.path.must_be :===, '/hello-world/index.html'
    end
  end

end
