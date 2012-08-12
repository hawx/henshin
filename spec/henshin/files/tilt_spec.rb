require_relative '../../helper'

describe Henshin::File::Tilt do

  subject { Henshin::File::Tilt }
  let(:site) { test_site }

  describe '#text' do
    it 'uses tilt to render the contents of the file' do
      path = Pathname.new('some-file.md')
      path.stubs(:read).returns <<EOS
---
title: Some File
---

A _lot_ of markdown is __good__ for `testing`.
EOS

      file = subject.new(site, path)

      file.text.must_equal "<p>A <em>lot</em> of markdown is <strong>good</strong> for <code>testing</code>.</p>\n"
    end
  end

end

describe Henshin::File::TiltTemplate do

  subject { Henshin::File::TiltTemplate }
  let(:site) { test_site }

  describe '#text' do
    it 'uses tilt to render the template' do
      path = Pathname.new('some-file.md')
      path.stubs(:read).returns <<EOS
---
title: Some File
---

A _lot_ of markdown is __good__ for `testing`.
EOS

      file = Henshin::File::Tilt.new(site, path)

      path = Pathname.new('template/page.slim')
      path.stubs(:read).returns <<EOS
h1 = title
== yield
EOS

      tmpl = subject.new(site, path)

      tmpl.stubs(:data).returns(file)
      tmpl.text.must_equal "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\" /><link href=\"&#47;style.css\" rel=\"stylesheet\" /><title>Some File</title></head><body><p>A <em>lot</em> of markdown is <strong>good</strong> for <code>testing</code>.</p>
<script src=\"&#47;script.js\"></script></body></html>"
    end
  end

end
