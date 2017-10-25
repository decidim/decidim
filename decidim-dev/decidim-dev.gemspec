# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/dev/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Dev.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-dev"
  s.summary = "Decidim Dev tools"
  s.description = "Utilities and tools we need to develop Decidim"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim", Decidim::Dev.version
  s.add_dependency "factory_girl_rails"
  s.add_dependency "database_cleaner", "~> 1.6"
  s.add_dependency "capybara", "~> 2.15"
  s.add_dependency "capybara-screenshot", "~> 1.0"

  s.add_dependency "rspec-rails", "~> 3.6", "< 3.7"
  s.add_dependency "rspec-repeat", "~> 1.0"
  s.add_dependency "byebug"
  s.add_dependency "wisper-rspec", "~> 0.0.3"
  s.add_dependency "listen", "~> 3.1"
  s.add_dependency "i18n-tasks", "0.9.18"
  s.add_dependency "poltergeist", "~> 1.16"
  s.add_dependency "rails-controller-testing", "~> 1.0"
  s.add_dependency "simplecov", "~> 0.13"
  s.add_dependency "codecov", "~> 0.1.9"
  s.add_dependency "rubocop", "~> 0.50.0"
  s.add_dependency "db-query-matchers", "~> 0.9.0"
  s.add_dependency "rspec-html-matchers", "~> 0.9.1"
  s.add_dependency "webmock", "~> 3.0"
  s.add_dependency "puma", "~> 3.10"
  s.add_dependency "nokogiri", "~> 1.8"
end
