# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/generators/version"

Gem::Specification.new do |s|
  s.version = Decidim::Generators.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-generators"

  s.summary = "Citizen participation framework for Ruby on Rails."
  s.description = "A generator and multiple gems made with Ruby on Rails."

  s.files = Dir[
    "lib/**/*",
    "Gemfile",
    "Gemfile.lock",
    "Rakefile",
    "README.md"
  ]

  s.bindir = "exe"
  s.executables = ["decidim"]
  s.require_paths = ["lib"]

  s.add_dependency "decidim-core", Decidim::Generators.version

  s.add_development_dependency "bundler", "~> 2.2"
end
