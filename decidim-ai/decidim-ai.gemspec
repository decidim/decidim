# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  version = "0.32.0.dev"
  s.version = version
  s.authors = ["Alexandru-Emil Lupu"]
  s.email = ["contact@alecslupu.ro"]
  s.license = "AGPL-3.0-or-later"
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = "~> 3.4.0"

  s.name = "decidim-ai"
  s.summary = "A Decidim module with AI tools"
  s.description = "A module that aims to provide Artificial Intelligence tools for Decidim."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "classifier-reborn", "~> 2.3.0"
  s.add_dependency "decidim-core", version
  s.add_development_dependency "decidim-debates", version
  s.add_development_dependency "decidim-initiatives", version
  s.add_development_dependency "decidim-meetings", version
  s.add_development_dependency "decidim-proposals", version
end
