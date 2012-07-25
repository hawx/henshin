require_relative '../../helper'

describe Henshin::EmptyTemplate do

  subject { Henshin::EmptyTemplate.new }

  it 'has #name of "none"' do
    subject.name.must_equal 'none'
  end

end
