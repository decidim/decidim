# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "decidim/version"

Gem::Specification.new do |s|
  s.version = Decidim.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3"

  s.name = "decidim"

  s.summary = "Citizen participation framework for Ruby on Rails."
  s.description = "A generator and multiple gems made with Ruby on Rails."

  s.files = Dir[
    "{docs,lib}/**/*",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  s.bindir = "exe"
  s.executables = ["decidim"]
  s.require_paths = ["lib"]

  s.add_dependency "decidim-accountability", Decidim.version
  s.add_dependency "decidim-admin", Decidim.version
  s.add_dependency "decidim-api", Decidim.version
  s.add_dependency "decidim-assemblies", Decidim.version
  s.add_dependency "decidim-budgets", Decidim.version
  s.add_dependency "decidim-comments", Decidim.version
  s.add_dependency "decidim-core", Decidim.version
  s.add_dependency "decidim-debates", Decidim.version
  s.add_dependency "decidim-meetings", Decidim.version
  s.add_dependency "decidim-pages", Decidim.version
  s.add_dependency "decidim-participatory_processes", Decidim.version
  s.add_dependency "decidim-proposals", Decidim.version
  s.add_dependency "decidim-sortitions", Decidim.version
  s.add_dependency "decidim-surveys", Decidim.version
  s.add_dependency "decidim-system", Decidim.version
  s.add_dependency "decidim-verifications", Decidim.version

  s.add_development_dependency "bundler", "~> 1.12"
  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
