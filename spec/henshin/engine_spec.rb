require_relative '../helper'

describe Henshin::Engine do
  subject { Henshin::Engine.new }

  describe '#render' do
    it 'returns the text, unchanged' do
      subject.render("apples").must_equal "apples"
    end
  end
end

describe Henshin::Engines do
  describe '.register' do
    it 'registers a new Engine'
  end

  describe '.find' do
    it 'returns the Engine with the given name'
  end

  describe '.render' do
    it 'renders the text with the correct Engine'
  end

  describe '.setup' do
    it 'sets up all the Engines'
  end

  describe '.each' do
    it 'iterates through each engine'
  end
end
