require_relative '../../helper'

describe Henshin::Publisher::Sftp do

  subject { Henshin::Publisher::Sftp }

  describe '#write' do

    let(:path) { Pathname.new('cool/file.txt') }
    let(:file) { mock.tap {|m| m.expects(:open).with("/#{path}", 'w') } }
    let(:conn) { stub(:file => file, :lstat! => false) }

    it 'writes the contents to the path' do
      with_writing! do
        sftp = subject.new(conn, Pathname.new('/'))
        sftp.write path, 'Hey'
      end
    end

  end
end
