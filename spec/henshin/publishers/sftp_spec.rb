require_relative '../../helper'

describe Henshin::SftpPublisher do

  subject { Henshin::SftpPublisher }



  describe Henshin::SftpPublisher::Writer do

    subject { Henshin::SftpPublisher::Writer }

    describe '#write' do

      let(:connection) {
        mock()
      }

      let(:file) {
        mock()
      }

      it 'writes the contents to the path' do
        with_writing! do
          sftp = subject.new(connection, Pathname.new('/'))
          connection.stubs(:file).returns(file)
          connection.stubs(:lstat!).returns(false)

          path = Pathname.new('cool/file.txt')
          contents = "Hey"

          file.expects(:open).with('/cool/file.txt', 'w')
          sftp.write path, contents
        end
      end
    end

  end

end
