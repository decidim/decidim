# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  Decidim.add_default_gemspec_properties(s)

  s.name        = "decidim-dev"
  s.summary     = "Decidim Dev tools"
  s.description = "Utilities and tools we need to develop Decidim"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim", Decidim.version
  s.add_dependency "factory_girl_rails"
  s.add_dependency "database_cleaner", "~> 1.5.0"
  s.add_dependency "capybara", "~> 2.12.0"
  s.add_dependency "capybara-screenshot", "~> 1.0.14"
  s.add_dependency "rspec-rails", "~> 3.5"
  s.add_dependency "rspec-repeat", "~> 1.0.2"
  s.add_dependency "byebug"
  s.add_dependency "wisper-rspec", "~> 0.0.3"
  s.add_dependency "listen", "~> 3.1.0"
  s.add_dependency "launchy"
  s.add_dependency "i18n-tasks", "0.9.12"
  s.add_dependency "faker", "~> 1.7.3"
  s.add_dependency "poltergeist", "~> 1.14.0"
  s.add_dependency "rails-controller-testing", "~> 1.0.1"
  s.add_dependency "simplecov", "~> 0.13"
  s.add_dependency "codecov", "~> 0.1.9"
  s.add_dependency "rubocop", "~> 0.47"
  s.add_dependency "db-query-matchers", "~> 0.7.0"
  s.add_dependency "letter_opener_web", "~> 1.3.0"
  s.add_dependency "rspec-html-matchers", "~> 0.9.1"
  s.add_dependency "webmock", "~> 2.3.2"
end
