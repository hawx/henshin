require_relative '../../helper'

describe Henshin::Tags do

  subject { Henshin::Tags }
  let(:site) { Henshin::Site.new }
  let(:posts) {
    []
  }
  let(:tags) { subject.new(site, posts) }

  describe '.create' do
    it 'creates tags'
  end

  describe '#data' do
    it 'returns all the data'
  end

end
