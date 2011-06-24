# If subject is a site:
#
#   it { should ignore 'config.yml' }
#
RSpec::Matchers.define :ignore do |path|
  match do |site|
    if path.is_a?(Pathname)
      site.ignores?(path)
    else
      site.ignores?(site.source + path)
    end
  end
  
  failure_message_for_should do |site|
    "expected that #{site.inspect} would ignore #{path}"
  end

  failure_message_for_should_not do |site|
    p path
    "expected that #{site.inspect} would not ignore #{path}"
  end

  description do
    "ignore #{path}"
  end
end