# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/templates/version"

Gem::Specification.new do |s|
  s.version = Decidim::Templates.version
  s.authors = ["Vera Rojman"]
  s.email = ["vrojman@protonmail.com"]
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

  s.name = "decidim-templates"
  s.summary = "A decidim templates module"
  s.description = "This module provides a solution to create templates for different Decidim models, such as Proposals and Questionnaires.."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Templates.version
  s.add_dependency "decidim-forms", Decidim::Templates.version

  s.add_development_dependency "decidim-admin", Decidim::Templates.version
  s.add_development_dependency "decidim-dev", Decidim::Templates.version
end
