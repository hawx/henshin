require_relative '../helper'

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

  let(:site) { Henshin::Site.new }

  subject { Henshin::Post }
  let(:post) { subject.new(site, 'posts/1-hello-world.md') }

  before {
    Henshin::Writer.dry_run!
    post.path.stubs(:read).returns(text)
  }

  describe '#text' do
    it 'returns the text, rendered, templated' do
      template = mock()
      template.expects(:text).returns("h1 Blag\n\n==yield")
      site.expects(:template).with('post').returns(template)

      post.text.must_equal "<h1>Blag</h1><p>So, a post. Finally?</p>\n"
    end
  end

  describe '#permalink' do
    it 'returns the permalink' do
      post.permalink.must_equal '/hello-world/index.html'
    end
  end

end
