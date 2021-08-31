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
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-dev"
  s.summary = "Decidim dev tools"
  s.description = "Utilities and tools we need to develop Decidim"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "capybara", "~> 3.24"
  s.add_dependency "decidim", Decidim::Dev.version
  s.add_dependency "factory_bot_rails", "~> 4.8"

  s.add_dependency "axe-core-rspec", "~> 4.1.0"
  s.add_dependency "byebug", "~> 11.0"
  s.add_dependency "db-query-matchers", "~> 0.10.0"
  s.add_dependency "erb_lint", "~> 0.0.35"
  s.add_dependency "i18n-tasks", "~> 0.9.18"
  s.add_dependency "mdl", "~> 0.5"
  s.add_dependency "nokogiri", "~> 1.12"
  s.add_dependency "parallel_tests", "~> 3.7"
  s.add_dependency "puma", "~> 5.0"
  s.add_dependency "rails-controller-testing", "~> 1.0"
  s.add_dependency "rspec-cells", "~> 0.3.4"
  s.add_dependency "rspec-html-matchers", "~> 0.9.1"
  s.add_dependency "rspec_junit_formatter", "~> 0.3.0"
  s.add_dependency "rspec-rails", "~> 4.0"
  s.add_dependency "rspec-retry", "~> 0.6.2"
  s.add_dependency "rubocop", "~> 0.92.0"
  s.add_dependency "rubocop-rails", "~> 2.8"
  s.add_dependency "rubocop-rspec", "= 1.43.2"
  s.add_dependency "selenium-webdriver", "~> 3.142"
  s.add_dependency "simplecov", "~> 0.19.0"
  s.add_dependency "simplecov-cobertura", "~> 1.3.1"
  # s.add_dependency "system_test_html_screenshots", "~> 0.2"
  s.add_dependency "w3c_rspec_validators", "~> 0.3.0"
  s.add_dependency "webmock", "~> 3.6"
  s.add_dependency "webpush", "~> 1.1"
  s.add_dependency "wisper-rspec", "~> 1.0"
end
