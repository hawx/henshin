require_relative '../../helper'

describe Henshin::Package::Script do

  let(:value) { Object.new }
  let(:site)  { stub(:config => {compress: { scripts: value }}) }

  subject     { Henshin::Package::Script }

  describe '#enabled?' do
    it 'uses value from site config' do
      package = subject.new(site, [])
      package.enabled?.must_equal value
    end
  end

end
