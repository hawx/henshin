require_relative '../../helper'

describe Henshin::ScriptPackage do

  let(:value) { Object.new }

  let(:site) {
    obj = Object.new
    obj.stubs(:config).returns compress: {
      scripts: value
    }
    obj
  }

  subject { Henshin::ScriptPackage }

  describe '#enabled?' do
    it 'uses value from site config' do
      package = subject.new(site, [])
      package.enabled?.must_equal value
    end
  end

end
