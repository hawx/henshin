require 'spec_helper'

describe Henshin::File::Page do

  subject { Henshin::File::Page.new(nil, nil) }
  
  describe "#output" do
    specify { subject.output.should == 'html' }
  end
  
  describe "#key" do
    specify { subject.key.should == :page }
  end

end