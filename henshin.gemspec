# -*- encoding: utf-8 -*-
require File.expand_path("../lib/henshin/version", __FILE__)

Gem::Specification.new do |s|
  s.name         = "henshin"
  s.author       = "Joshua Hawxwell"
  s.email        = "m@hawx.me"
  s.summary      = "Another static site generator."
  s.homepage     = "http://github.com/hawx/henshin"
  s.version      = Henshin::VERSION

  s.description  = <<-DESC
    Another static site generator. Simple, focused, fast. Generates only
    changed files.
  DESC

  s.add_dependency 'rack', '~> 1.4'
  s.add_dependency 'redcarpet', '~> 2.1'
  s.add_dependency 'sass', '~> 3.1'
  s.add_dependency 'slim', '~> 1.2'
  s.add_dependency 'clive', '~> 1.1'

  s.add_development_dependency 'pelusa', '~> 0.2.0'
  s.add_development_dependency 'minitest', '~> 2.12'

  s.files        = %w(README.md LICENCE Rakefile)
  s.files       += Dir["{bin,lib,spec,site}/**/*"] & `git ls-files`.split("\n")
  s.test_files   = Dir["spec/**/*"] & `git ls-files`.split("\n")
  s.executables  = %w(henshin)
end
