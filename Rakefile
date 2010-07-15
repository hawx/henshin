require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "henshin"
    gem.summary = %Q{Henshin is a static site generator}
    gem.description = %Q{Henshin is a static site generator, with a plugin system and more}
    gem.email = "m@hawx.me"
    gem.homepage = "http://github.com/hawx/henshin"
    gem.authors = ["hawx"]
    gem.add_dependency "titlecase", ">= 0.1.0"
    gem.add_dependency "directory_watcher", ">= 1.3.1"
    gem.add_dependency "maruku", ">= 0.6.0"
    gem.add_dependency "liquid", ">= 2.0.0"
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "yard", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
