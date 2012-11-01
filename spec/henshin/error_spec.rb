require_relative '../helper'

describe Henshin::Error do

  subject { Henshin::Error }

  describe '.prettify' do
    it 'shows a nice reduced error' do
      err = nil
      begin
        raise StandardError
      rescue => induced
        err = induced
      end

      subject.stubs(:exit)

      # ...
    end
  end

end
