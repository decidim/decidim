# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/generators/version"

Gem::Specification.new do |s|
  s.version = Decidim::Generators.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3"

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

  compatible_constraint = "#{Gem::Version.new(s.version).approximate_recommendation}.a"

  s.add_dependency "decidim-core", compatible_constraint

  s.add_development_dependency "bundler", "~> 1.12"
end
