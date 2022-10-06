# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Api.version
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
  s.required_ruby_version = ">= 3.1"

  s.name = "decidim-api"
  s.summary = "Decidim API module"
  s.description = "API engine for decidim"

  s.files = Dir["{app,config,db,lib,vendor,docs}/**/*", "Rakefile", "README.md"]

  s.add_dependency "graphql", "~> 1.12", "< 1.13"
  s.add_dependency "graphql-docs", "~> 2.1.0"
  s.add_dependency "rack-cors", "~> 1.0"
  s.add_development_dependency "decidim-comments", Decidim::Api.version
  s.add_development_dependency "decidim-core", Decidim::Api.version
  s.add_development_dependency "decidim-dev", Decidim::Api.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Api.version
end
