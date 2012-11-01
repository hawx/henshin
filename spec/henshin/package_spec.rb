require_relative '../helper'

describe Henshin::Package do

  subject { Henshin::Package }

  let(:compressor) { mock() }
  let(:site) { test_site }
  let(:package) { subject.new(site, compressor) }

  describe '#text' do
    it 'returns the compressed text if #enabled?' do
      compressor.expects(:compress)
      package.text
    end

    it 'returns the joined text when not #enabled?' do
      package.stubs(:enabled?).returns(false)
      compressor.expects(:join)
      package.text
    end
  end

end
