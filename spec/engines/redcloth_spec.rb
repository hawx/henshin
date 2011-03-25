require 'spec_helper'

describe Henshin::RedCloth do

  subject { Henshin::RedCloth.new }
  
  describe "#render" do
    it "returns the rendered content" do
      text = <<EOS
h1. Textile

Yep that's right *textile*

highlight. ruby
  def sq(x)
    x * x
  end

EOS

      result = '<h1>Textile</h1>
<p>Yep that&#8217;s right <strong>textile</strong></p>
<pre class="highlight ruby"><code><span class="k">def</span> <span class="nf">sq</span><span class="p">(</span><span class="n">x</span><span class="p">)</span>
    <span class="n">x</span> <span class="o">*</span> <span class="n">x</span>
  <span class="k">end</span></code></pre>'
      
      subject.render(text, {}).should == result
    
    end
  end

end