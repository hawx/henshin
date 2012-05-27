require_relative '../helper'

describe Henshin::Package do

  subject { Henshin::Package }

  let(:compressor) { mock() }
  let(:site) { test_site }
  let(:package) { subject.new(site, compressor) }

  describe '#text' do
    it 'returns the compressed text' do
      compressor.expects(:compress)
      package.text
    end
  end

end
