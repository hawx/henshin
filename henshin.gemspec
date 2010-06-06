# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{henshin}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["hawx"]
  s.date = %q{2010-06-06}
  s.default_executable = %q{henshin}
  s.description = %q{Henshin is a static site generator, with a plugin system and more}
  s.email = %q{m@hawx.me}
  s.executables = ["henshin"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "bin/henshin",
     "henshin.gemspec",
     "lib/henshin.rb",
     "lib/henshin/categories.rb",
     "lib/henshin/ext.rb",
     "lib/henshin/gen.rb",
     "lib/henshin/plugin.rb",
     "lib/henshin/plugins/liquid.rb",
     "lib/henshin/plugins/maruku.rb",
     "lib/henshin/plugins/pygments.rb",
     "lib/henshin/plugins/sass.rb",
     "lib/henshin/plugins/textile.rb",
     "lib/henshin/post.rb",
     "lib/henshin/site.rb",
     "lib/henshin/static.rb",
     "lib/henshin/tags.rb",
     "test/helper.rb",
     "test/site/_site/2010/10/20-testing-stuff/index.html",
     "test/site/_site/2010/5/15-lorem-ipsum/index.html",
     "test/site/_site/css/print.css",
     "test/site/_site/index.html",
     "test/site/_site/static.html",
     "test/site/css/print.sass",
     "test/site/css/screen.css",
     "test/site/index.html",
     "test/site/layouts/category_index.html",
     "test/site/layouts/category_page.html",
     "test/site/layouts/main.html",
     "test/site/layouts/post.html",
     "test/site/layouts/tag_index.html",
     "test/site/layouts/tag_page.html",
     "test/site/options.yaml",
     "test/site/plugins/test.rb",
     "test/site/posts/Testing-Stuff.markdown",
     "test/site/posts/Textile-Test.textile",
     "test/site/posts/cat/test.markdown",
     "test/site/posts/lorem-ipsum.markdown",
     "test/site/posts/same-date.markdown",
     "test/site/static.html",
     "test/test_gens.rb",
     "test/test_henshin.rb",
     "test/test_layouts.rb",
     "test/test_options.rb",
     "test/test_posts.rb",
     "test/test_site.rb"
  ]
  s.homepage = %q{http://github.com/hawx/henshin}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Henshin is a static site generator}
  s.test_files = [
    "test/helper.rb",
     "test/site/plugins/test.rb",
     "test/test_gens.rb",
     "test/test_henshin.rb",
     "test/test_layouts.rb",
     "test/test_options.rb",
     "test/test_posts.rb",
     "test/test_site.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

