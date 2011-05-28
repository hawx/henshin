require 'spec_helper'

describe Kernel do

  describe '#autoload_gem' do
    subject { mock(Object.new) }
  
    it "should not load the gem until the constant is used" do
    end
  end

end

describe String do

  describe "#slugify" do
    it "turns a string into a slug" do
      "'Hello' I am a string  ".slugify.should == "hello-i-am-a-string"
    end
  end
  
  describe "#pluralize" do
    it "acts as an alias for #en#plural" do
      s = "dog"
      m = mock(Object)
      s.should_receive(:en).and_return(m)
      m.should_receive(:plural)
      s.pluralize
    end
  end

end

describe Hash do

  describe "#r_merge" do
    it "recursively merges two hashes" do
      a = {
        :a => {
          :b => {
           :c => 'hey',
           :d => 'hello'
          }
        },
        :e => 'what'
      }
      b = {
        :a => {
          :b => {
            :d => 'another'
          }
        },
        :f => 'yep'
      }
      c = {
        :a => {
          :b => {
            :c => 'hey',
            :d => 'another'
          }
        },
        :e => 'what',
        :f => 'yep'
      }
      
      a.r_merge(b).should == c
    
    end
  end

end
