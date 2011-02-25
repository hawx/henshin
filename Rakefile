require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


namespace :console do
  task :default => :basic

  desc "Load stuff in IRB."
  task :basic do
    exec "irb -rubygems -I lib -r henshin"
  end
  
  desc "Load and read site into IRB"
  task :load do
    exec "irb -rubygems -I lib -r henshin -r henshin/irb"
  end
end