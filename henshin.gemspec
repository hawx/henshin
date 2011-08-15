# -*- encoding: utf-8 -*-
require File.expand_path("../lib/henshin/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "henshin"
  s.author      = "Joshua Hawxwell"
  s.email       = "m@hawx.me"
  s.homepage    = "http://github.com/hawx/henshin"
  s.summary     = "An abstracted static site generator"
  s.version     = Henshin::VERSION
  s.required_ruby_version = '>= 1.9'
  
  s.description = <<-EOD
    Henshin is an abstracted static site generator, use it to build a personal
    blog, or personal site. Or take it to the next level(!) by creating a subclass
    of Henshin::Base and defining a custom structure to build from.
  EOD
  
  s.add_dependency 'titlecase',   '~> 0.1.1'
  s.add_dependency 'linguistics', '~> 1.0.8'
  s.add_dependency 'attr_plus',   '~> 0.4.0'
  s.add_dependency 'clive',       '~> 0.8.0'
  s.add_dependency 'rack',        '~> 1.2.2'
  
  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency 'duvet', '~> 0.3.3'
  
  s.files        = %w(Rakefile README.md LICENSE)
  s.files       += Dir["{bin,examples,lib,man,spec}/**/*"] & `git ls-files`.split("\n")
  s.test_files   = Dir["spec/**/*"] & `git ls-files`.split("\n")
  s.executables  = ["henshin"]
end
