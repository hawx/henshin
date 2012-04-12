require 'rake/testtask'

Rake::TestTask.new :test do |t|
  t.libs << 'lib' << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
end

task :lint do
  system "RBENV_VERSION='rbx-2.0.0-dev' sh -c 'rbx -S pelusa'"
end

task :default => :test
