# -*- encoding: utf-8 -*-
require File.expand_path("../lib/henshin/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "henshin"
  s.version     = Henshin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Joshua Hawxwell"
  s.email       = "m@hawx.me"
  s.homepage    = "http://github.com/hawx/henshin"
  s.has_rdoc    = false
  s.summary     = "An abstracted static site generator"
  s.description = <<-EOD
    Henshin is an abstracted static site generator, use it to build a personal
    blog, or personal site. Or take it to the next level by creating a subclass
    of Henshin::Base and defining a custom structure to build from.
  EOD
  
  s.add_dependency 'titlecase', ">= 0.1.0"
  s.add_dependency 'directory_watcher', ">= 1.3.1"
  s.add_dependency 'parsey', ">= 0.1.3"
  
  s.add_development_dependency 'thoughtbot-shoulda', ">= 0"
  s.add_development_dependency "rspec", ">= 2.1"
  
  # only git-ted files should be used when building
  s.files        = Dir['Rakefile', 'LICENSE', 'README.md', '{bin,lib,test}/**/*'] & `git ls-files -z`.split("\0")
  s.test_files   = Dir.glob("test/**/*")
  
  s.executables  = ["henshin"]
  s.require_path = 'lib'
end
