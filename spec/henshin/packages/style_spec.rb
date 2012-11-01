require_relative '../../helper'

describe Henshin::Package::Style do

  let(:value) { Object.new }
  let(:site)  { stub(:config => {compress: {styles: value}}) }

  subject     { Henshin::Package::Style }

  describe '#enabled?' do
    it 'uses value from site config' do
      package = subject.new(site, [])
      package.enabled?.must_equal value
    end
  end

end
