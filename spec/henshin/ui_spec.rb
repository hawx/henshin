require_relative '../helper'

describe Henshin::UI do

  subject { Henshin::UI }

  # before { Henshin.unset :colour }
  # after  { Henshin.set   :colour }

  describe '.notify' do
    it 'outputs a message with a given status' do
      proc {
        subject.notify("HEY", "it does stuff")
      }.must_output "           HEY  it does stuff\n"
    end
  end

  describe '.wrote' do
    it 'prints the time taken as well' do
      proc {
        subject.wrote('/file', 0.345)
      }.must_output '  ' + '0.345s '.grey + 'wrote'.green.bold + "  /file\n"
    end
  end

end
