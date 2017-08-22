# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require_relative "../decidim-core/lib/decidim/core/version"

Gem::Specification.new do |s|
  Decidim.add_default_gemspec_properties(s)

  s.name = "decidim-participatory_processes"
  s.summary = "Participatory Processes plugin for decidim"
  s.description = s.summary

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim.version
  s.add_dependency "rails", *Decidim.rails_version

  s.add_development_dependency "decidim-dev", Decidim.version
  s.add_development_dependency "decidim-admin", Decidim.version
end
