require_relative '../helper'

describe Henshin::Engine do

end

describe Henshin::CoffeeScriptEngine do
  subject { Henshin::CoffeeScriptEngine }
  before { subject.setup }

  it 'renders coffeescript' do
    input = <<EOS
sq = (x) -> x * x
alert sq(4)
EOS

    subject.render(input).must_equal <<EOS
(function() {
  var sq;

  sq = function(x) {
    return x * x;
  };

  alert(sq(4));

}).call(this);
EOS
  end
end

describe Henshin::RedcarpetEngine do
  subject { Henshin::RedcarpetEngine }
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

describe Henshin::SassEngine do
  subject { Henshin::SassEngine }
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

describe Henshin::SlimEngine do
  subject { Henshin::SlimEngine }
  before { subject.setup }

  it 'renders slim' do
    input = <<EOS
doctype html
html
  head
    title = title

body
  h1 = title

  == yield
EOS

    data = {:title => "Test", :yield => "Hey guys!"}
    res = subject.render(input, data).must_equal "<!DOCTYPE html><html><head><title>Test</title></head\
></html><body><h1>Test</h1>Hey guys!</body>"

  end
end
