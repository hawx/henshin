require 'spec_helper'

describe Henshin::Base do

  subject { 
    config = {
      :read_path  => File.dirname(__FILE__) + '/../test_site',
      :write_path => File.dirname(__FILE__) + '/../test_site/_site'
    }
    Henshin::Base.new(config) 
  }
  
  it "should have configuration" do
    config_hash = {
      :read_path => File.dirname(__FILE__) + '/../test_site',
      :write_path => File.dirname(__FILE__) + '/../test_site/_site'
    }
    subject.config.should == Henshin::Base::DEFAULTS.merge(config_hash)
  end
  
  describe "#relative_path" do
    it "should create a relative path" do
      
    end
  end
  
  describe "#read" do
  
  end
  
  describe "#write" do
  
  end
  
  describe "#payload" do
    it "should include the configuration" do
      subject.payload['site'].should include subject.config
    end
    
    it "should include an array of files hashes" do
      subject.payload['files'].should be_kind_of Array
    end
    
  end
  
end