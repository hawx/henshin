require 'rake'
require 'rspec/core/rake_task'

GEM_SPEC = eval(File.read('henshin.gemspec'))

RSpec::Core::RakeTask.new(:fast) do |t|
  t.rspec_opts = "--tag \\~renders"
end

RSpec::Core::RakeTask.new(:spec)

task :man do
  ENV['RONN_ORGANIZATION'] = "Henshin #{GEM_SPEC.version}"
  sh "ronn -5r -stoc man/*.ronn"
end

task :default => :spec
