require_relative '../../helper'

describe Henshin::File::EmptyTemplate do

  subject { Henshin::File::EmptyTemplate.new }

  it 'has #name of "none"' do
    subject.name.must_equal 'none'
  end

end
