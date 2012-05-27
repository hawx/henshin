require_relative '../../helper'

describe Henshin::SassEngine do
  subject { Henshin::SassEngine.new }
  before { subject.setup }

  it 'renders sass' do
    input = <<EOS
body
  color: rgba(red, .5)
EOS

    subject.render(input).must_equal <<EOS
body {
  color: rgba(255, 0, 0, 0.5); }
EOS
  end
end
