# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/templates/version"

Gem::Specification.new do |s|
  s.version = Decidim::Templates.version
  s.authors = ["Vera Rojman"]
  s.email = ["vrojman@protonmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-templates"
  s.required_ruby_version = ">= 3.1"

  s.name = "decidim-templates"
  s.summary = "A decidim templates module"
  s.description = "This module provides a solution to create templates for different Decidim models, such as Proposals and Questionnaires.."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Templates.version
  s.add_dependency "decidim-forms", Decidim::Templates.version

  s.add_development_dependency "decidim-admin", Decidim::Templates.version
  s.add_development_dependency "decidim-dev", Decidim::Templates.version
end
