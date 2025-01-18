# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/dev/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Dev.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0-or-later"
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = "~> 3.3.0"

  s.name = "decidim-dev"
  s.summary = "Decidim dev tools"
  s.description = "Utilities and tools we need to develop Decidim"

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ Rakefile README.md rubocop-decidim.yml))
    end
  end

  s.add_dependency "bullet", "~> 8.0.0"
  s.add_dependency "byebug", "~> 11.0"
  s.add_dependency "capybara", "~> 3.39"
  s.add_dependency "decidim-admin", Decidim::Dev.version
  s.add_dependency "decidim-api", Decidim::Dev.version
  s.add_dependency "decidim-comments", Decidim::Dev.version
  s.add_dependency "decidim-core", Decidim::Dev.version
  s.add_dependency "decidim-generators", Decidim::Dev.version
  s.add_dependency "decidim-verifications", Decidim::Dev.version
  s.add_dependency "erb_lint", "~> 0.8.0"
  s.add_dependency "factory_bot_rails", "~> 6.2"
  s.add_dependency "faker", "~> 3.2"
  s.add_dependency "i18n-tasks", "~> 1.0"
  s.add_dependency "nokogiri", "~> 1.16", ">= 1.16.2"
  s.add_dependency "parallel_tests", "~> 4.2"
  s.add_dependency "puma", "~> 6.5"
  s.add_dependency "rails-controller-testing", "~> 1.0"
  s.add_dependency "rspec", "~> 3.12"
  s.add_dependency "rspec-cells", "~> 0.3.7"
  s.add_dependency "rspec-html-matchers", "~> 0.10"
  s.add_dependency "rspec_junit_formatter", "~> 0.6.0"
  s.add_dependency "rspec-rails", "~> 7.0"
  s.add_dependency "rspec-retry", "~> 0.6.2"
  s.add_dependency "rubocop", "~> 1.69.0"
  s.add_dependency "rubocop-capybara", "~> 2.21"
  s.add_dependency "rubocop-factory_bot", "~> 2.26"
  s.add_dependency "rubocop-faker", "~> 1.1"
  s.add_dependency "rubocop-performance", "~> 1.21"
  s.add_dependency "rubocop-rails", "~> 2.25"
  s.add_dependency "rubocop-rspec", "~> 3.0"
  s.add_dependency "rubocop-rspec_rails", "~> 2.30"
  s.add_dependency "rubocop-rubycw", "~> 0.1"
  s.add_dependency "selenium-webdriver", "~> 4.9"
  s.add_dependency "simplecov", "~> 0.22.0"
  s.add_dependency "simplecov-cobertura", "~> 2.1.0"
  s.add_dependency "spring", "~> 4.0"
  s.add_dependency "spring-watcher-listen", "~> 2.0"
  s.add_dependency "w3c_rspec_validators", "~> 0.3.0"
  s.add_dependency "webmock", "~> 3.18"
  s.add_dependency "wisper-rspec", "~> 1.0"
end
