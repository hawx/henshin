require 'spec_helper'

describe Henshin::Delegator do

  subject {
    Class.new {
      extend Henshin::Delegator
      
      def initialize(stuff=[])
        @array = stuff
      end
      attr_reader :array
      
      delegates :@array, :<<, :[], :push, :pop
      
      def self.hello(name)
        "Hello, #{name}!"
      end
      delegate :class, :hello, :hey
    }
  }
  
  describe ".delegate" do
    let(:instance) { subject.new }
  
    it "defines a method given a method symbol" do
      subject.class_eval { delegate :class, :hello, :x }
      instance.should respond_to :x
      instance.x("world").should == "Hello, world!"
    end
    
    it "defines a method given an instance variable" do
      subject.class_eval { delegate :@array, :inspect, :y }
      instance.should respond_to :y
      instance.y.should == "[]"
    end
    
    it "defaults to using the same method name" do
      subject.class_eval { delegate :@array, :inspect }
      instance.inspect.should == "[]"
    end
  end
  
  describe ".delegates" do
    it "calls .delegate with each method" do
      subject.should_receive(:delegate).with(:@array, :x, :x)
      subject.should_receive(:delegate).with(:@array, :y, :y)
      subject.should_receive(:delegate).with(:@array, :z, :z)
      subject.class_eval { delegates :@array, :x, :y, :z }
    end
  end

end