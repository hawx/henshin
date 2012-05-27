require_relative '../../helper'

describe Henshin::SlimEngine do
  subject { Henshin::SlimEngine.new }
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
