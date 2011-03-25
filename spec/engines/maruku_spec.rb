require 'spec_helper'

describe Henshin::Maruku do
  
  subject { Henshin::Maruku.new }
  
  describe "#render" do
    it "returns the rendered content" do
      text = <<EOS
# Header

Yes __markdown__

$ highlight ruby
def sq(x)
  x * x
end
$ end
EOS
      result = "<h1 id='header'>Header</h1>

<p>Yes <strong>markdown</strong></p>
<pre class='highlight ruby'><code><span class='k'>def</span> <span class='nf'>sq</span><span class='p'>(</span><span class='n'>x</span><span class='p'>)</span>
  <span class='n'>x</span> <span class='o'>*</span> <span class='n'>x</span>
<span class='k'>end</span></code></pre>"

      subject.render(text, {}).should == result
    end
  end

end