# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/ai/version"

Gem::Specification.new do |s|
  s.version = Decidim::Ai.version
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
  s.required_ruby_version = "~> 3.3.0"

  s.name = "decidim-ai"
  s.summary = "A Decidim module with AI tools"
  s.description = "A module that aims to provide Artificial Intelligence tools for Decidim."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "classifier-reborn", "~> 2.3.0"
  s.add_dependency "decidim-core", Decidim::Ai.version
  s.add_development_dependency "decidim-debates", Decidim::Ai.version
  s.add_development_dependency "decidim-initiatives", Decidim::Ai.version
  s.add_development_dependency "decidim-meetings", Decidim::Ai.version
  s.add_development_dependency "decidim-proposals", Decidim::Ai.version
end
