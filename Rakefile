require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:fast) do |t|
  t.rspec_opts = "--tag \\~renders"
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
