require_relative '../helper'

describe Henshin::UI do

  subject { Henshin::UI }

  describe '.notify' do
    it 'outputs a message with a given status' do
      proc {
        subject.notify("HEY", "it does stuff")
      }.must_output "           HEY  it does stuff\n"
    end
  end

  describe '.wrote' do
    it 'prints the time taken as well'
  end

end
