require_relative '../helper'

describe Henshin::File do

  let(:site) { Object.new }
  subject { Henshin::File }

  describe 'registering new file type' do
    it 'is picked up by .create' do
      klass = Class.new(subject::Physical)
      subject.register /\.test/, klass

      file = subject.create(site, Pathname.new('something.test'))
      file.class.must_equal klass
    end
  end

  describe 'registering new module to apply' do
    it 'is picked up by .create' do
      mod = Module.new
      subject.apply /\.apply/, mod

      file = subject.create(site, Pathname.new('something.apply'))
      file.singleton_class.ancestors.must_include mod
    end
  end

end
