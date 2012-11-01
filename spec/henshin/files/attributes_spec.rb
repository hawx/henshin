require_relative '../../helper'

describe Henshin::File::Attributes do

  subject {
    obj = Object.new
    obj.extend Henshin::File::Attributes
    obj
  }

  describe '#requires' do
    it 'adds a required key to the list' do
      subject.requires :apples
      subject.required.must_include :apples
    end
  end

  describe '#required' do
    it 'returns the required keys' do
      subject.requires :apples, :oranges
      subject.required.to_a.must_equal [:apples, :oranges]
    end
  end

end
