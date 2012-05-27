require_relative '../../helper'

describe Henshin::Template do

  subject { Henshin::Template }
  let(:site) { test_site }
  let(:path) { Pathname.new('templates/default.slim') }
  let(:template) {
    f = Henshin::SlimFile.new(site, path)
    f.extend Henshin::Template
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

      res = template.template(:title => "Cool post",
                              :yield => "<p>Hey so here is the text.</p>")

      res.must_equal "<h1>Cool post</h1><p>Hey so here is the text.</p>"
    end
  end

end
