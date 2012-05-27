require_relative '../helper'

describe Henshin::Publisher do

  subject { Henshin::Publisher }

  describe '.requires_keys' do
    it 'returns true if the hash contains every key' do
      hash = {a: 1, b: 2, c: 3}
      list = [:a, :b]
      subject.requires_keys(hash, list).must_equal true
    end
  end

  describe '.get_required_opt' do
    it 'returns the option' do
      subject.get_required_opt({:a => 1}, :a).must_equal 1
    end

    it 'fails loudly' do
      Henshin::UI.expects(:fail).with("Must give :a option to publish.")
      subject.get_required_opt({}, :a)
    end
  end

  describe '.get_password' do
    it 'returns the password from the hash' do
      subject.get_password({:pass => 'a'}, :pass).must_equal 'a'
    end

    it 'executes the command given' do
      subject.get_password({:pass => '$sh echo "hello"'}, :pass).
        must_equal 'hello'
    end

    it 'prompts for password' do
      m = mock()
      m.expects(:ask)
      HighLine.expects(:new).returns(m)

      subject.get_password({}, :pass)
    end
  end

end
