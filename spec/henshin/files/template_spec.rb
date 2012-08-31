require_relative '../../helper'

describe Henshin::File::Template do

  subject { Henshin::File::Template }
  let(:site) { test_site }
  let(:path) { Pathname.new('templates/default.slim') }
  let(:template) {
    f = Henshin::File::TiltTemplate.new(site, path)
    f.extend subject
    f
  }

  describe '#name' do
    it 'returns the name' do
      template.name.must_equal 'default'
    end
  end

  describe '#template' do
    it 'renders the template with the given data' do
      path.stubs(:read).returns <<EOS
h1 = title
== yield
EOS

      other = Henshin::File::Physical.new(site, 'sometest.md')
      other.stubs(:title).returns('Cool post')
      other.stubs(:text).returns('<p>Hey so here is the text.</p>')
      other.instance_variable_get(:@path).stubs(:read).returns <<EOS
---
title: Cool post
---

Hey so here is the text.
EOS

      template.template(other).must_equal "<h1>Cool post</h1><p>Hey so here is the text.</p>"
    end

    it 'disallows writing' do
      path.stubs(:read).returns <<EOS
p = write(Object.new)
EOS

      other = Henshin::File::Physical.new(site, Pathname.new('sometest.md'))
      other.instance_variable_get(:@path).stubs(:read).returns("")

      template.template(other).must_equal "<p></p>"
    end
  end

end
