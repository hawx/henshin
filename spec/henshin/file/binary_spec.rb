require 'spec_helper'

describe Henshin::File::Binary do

  subject { Henshin::File::Binary.new(nil, nil) }
  
  it { should be_readable }
  it { should_not be_renderable }
  it { should_not be_layoutable }
  it { should be_writeable }

end