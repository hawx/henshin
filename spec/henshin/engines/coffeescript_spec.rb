require_relative '../../helper'

describe Henshin::CoffeeScriptEngine do
  subject { Henshin::CoffeeScriptEngine.new }
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
