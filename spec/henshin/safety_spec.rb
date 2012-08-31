require_relative '../helper'

describe Henshin::Safety do

  subject {
    Class.new {
      include Henshin::Safety

      def unsafe_method; "Hey, I was called!"; end
      unsafe :unsafe_method

      def another(a, b, c); "Yes, called again"; end
      unsafe :another

      def safe_method; "Ok here"; end
    }.new
  }

  describe 'a normally created object including Safety' do
    it 'can call marked methods normally' do
      subject.unsafe_method.must_equal "Hey, I was called!"
    end
  end

  describe '#safe' do
    let(:unsafe) { subject }
    let(:safe)   { unsafe.safe }

    it 'returns a copy of the object' do
      safe.wont_equal unsafe
      safe.must_be_instance_of unsafe.class
    end

    it 'with the unsafe methods stubbed' do
      safe.unsafe_method.must_equal nil
    end

    it 'works for methods expecting arguments' do
      safe.another(1, 2, 3).must_equal nil
    end

    it 'unmarked methods still work' do
      safe.safe_method.must_equal "Ok here"
    end
  end

end
