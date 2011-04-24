require 'spec_helper'
require 'henshin/engine/slim'

describe Henshin::Engine::Slim do
  
  subject { Henshin::Engine::Slim.new }
  
  describe "#render" do
    it "returns the rendered content" do
      text = <<EOS
h1 Foods
ul
  - site.array.each do |i|
    li Item: \#{i}
      
h1 Code
highlight:
  $ruby
  
  def sq(x)
    x * x
  end
  
p That's all folks
EOS

      result = '<h1>Foods</h1><ul><li>Item: apple</li><li>Item: banana</li><li>Item: carrot</li></ul><h1>Code</h1><pre class="highlight ruby"><code><span class="k">def</span> <span class="nf">sq</span><span class="p">(</span><span class="n">x</span><span class="p">)</span>
  <span class="n">x</span> <span class="o">*</span> <span class="n">x</span>
<span class="k">end</span></code></pre><p>That\'s all folks</p>'

      subject.render(text, {'site' => {'array' => %w(apple banana carrot)}}).should == result
    end
  end

end