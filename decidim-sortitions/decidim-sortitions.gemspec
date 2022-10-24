# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/sortitions/version"

Gem::Specification.new do |s|
  s.version = Decidim::Sortitions.version
  s.authors = ["Juan Salvador Perez Garcia"]
  s.email = ["jsperezg@gmail.com"]
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

  s.name = "decidim-sortitions"
  s.summary = "Decidim sortitions module"
  s.description = "This module makes possible to select amont a set of proposal by sortition"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", Decidim::Sortitions.version
  s.add_dependency "decidim-comments", Decidim::Sortitions.version
  s.add_dependency "decidim-core", Decidim::Sortitions.version
  s.add_dependency "decidim-proposals", Decidim::Sortitions.version

  s.add_development_dependency "decidim-dev", Decidim::Sortitions.version
end
