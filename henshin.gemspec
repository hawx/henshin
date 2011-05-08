# -*- encoding: utf-8 -*-
require File.expand_path("../lib/henshin/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "henshin"
  s.version     = Henshin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Joshua Hawxwell"
  s.email       = "m@hawx.me"
  s.homepage    = "http://github.com/hawx/henshin"
  s.summary     = "An abstracted static site generator"
  s.description = <<-EOD
    Henshin is an abstracted static site generator, use it to build a personal
    blog, or personal site. Or take it to the next level(!) by creating a subclass
    of Henshin::Base and defining a custom structure to build from.
  EOD
  
  s.add_dependency 'titlecase', "~> 0.1.1"
  s.add_dependency 'linguistics', "~> 1.0.8"
  s.add_dependency 'attr_plus', "~> 0.2.0"
  s.add_dependency 'clive', "~> 0.8.0"
  s.add_dependency 'shuber-interface', '~> 0.0.4'
  s.add_dependency 'rack', '~> 1.2.2'
  
  s.add_dependency 'liquid'
  s.add_dependency 'slim'
  s.add_dependency 'rdiscount'
  s.add_dependency 'nokogiri'
  s.add_dependency 'kramdown'
  s.add_dependency 'coffee-script'
  s.add_dependency 'builder'
  s.add_dependency 'ultraviolet'
  s.add_dependency 'syntax'
  
  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency 'duvet', '~> 0.3.1'
  
  # only git-ted files should be used when building
  s.files        = Dir['Rakefile', 'LICENSE', 'README.md', '{bin,lib,test}/**/*'] & `git ls-files -z`.split("\0")
  s.test_files   = Dir.glob("test/**/*")
  
  s.executables  = ["henshin"]
  s.require_path = 'lib'
end
