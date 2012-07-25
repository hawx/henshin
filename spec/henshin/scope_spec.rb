require_relative '../helper'

describe Henshin::Scope do

  subject { Henshin::Scope }

  describe '#initialize' do
    it 'creates a method for each key-value' do
      scope = subject.new a: 1, b: 2
      scope.a.must_equal 1
      scope.b.must_equal 2
    end

    it 'works recursively on hashes' do
      scope = subject.new a: {b: {c: 3}}
      scope.a.b.c.must_equal 3
    end

    it 'works on arrays of hashes' do
      scope = subject.new a: [{b: 2}, {c: {d: 4}}]
      scope.a[0].b.must_equal 2
      scope.a[1].c.d.must_equal 4
    end
  end

  describe '#method_missing' do
    it 'returns nil for unknowns' do
      scope = subject.new bye: 1
      scope.hello.must_equal nil
    end
  end

end
