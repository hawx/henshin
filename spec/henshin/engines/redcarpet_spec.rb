require_relative '../../helper'

describe Henshin::RedcarpetEngine do
  subject { Henshin::RedcarpetEngine.new }
  before { subject.setup }

  it 'renders markdown' do
    input = <<EOS
# A Test

Yes a test. A great man once said

> This is a test.
EOS

    subject.render(input).must_equal <<EOS
<h1>A Test</h1>

<p>Yes a test. A great man once said</p>

<blockquote>
<p>This is a test.</p>
</blockquote>
EOS
  end
end
