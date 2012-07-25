require_relative '../helper'

describe Hash do

  describe '#symbolise' do
    it 'changes string keys to symbols' do
      {'a' => 1}.symbolise.must_equal :a => 1
    end

    it 'works recursively' do
      {'a' => {'b' => 2}}.symbolise.must_equal :a => {:b => 2}
    end
  end

  describe '#deep_merge' do
    it 'merges a hash into another hash' do
      a = {a: {b: 1, d: 4}}
      b = {a: {b: 2, c: 3}}
      c = {a: {b: 2, c: 3, d: 4}}

      a.deep_merge(b).must_equal c
    end
  end

end

describe String do

  describe '#slugify' do
    it 'turns a string into a nice slug' do
      s = "Oh god, wait? I've got wierd   bits in-this=string...    "
      r = "oh-god-wait-ive-got-wierd-bits-in-this-string"

      s.slugify.must_equal r
    end
  end

end
