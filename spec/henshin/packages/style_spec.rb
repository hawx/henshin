require_relative '../../helper'

describe Henshin::StylePackage do

  let(:value) { Object.new }

  let(:site) {
    obj = Object.new
    obj.stubs(:config).returns compress: {
      styles: value
    }
    obj
  }

  subject { Henshin::StylePackage }

  describe '#enabled?' do
    it 'uses value from site config' do
      package = subject.new(site, [])
      package.enabled?.must_equal value
    end
  end

end
