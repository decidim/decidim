# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  Decidim.add_default_gemspec_properties(s)

  s.name = "decidim-proposals"
  s.summary = "A proposals component for decidim's participatory processes."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim.version
  s.add_dependency "decidim-comments", Decidim.version
  s.add_dependency "kaminari", "~> 1.0.1"
  s.add_dependency "social-share-button", "~> 1.0.0"

  s.add_development_dependency "decidim-dev", Decidim.version
  s.add_development_dependency "decidim-admin", Decidim.version
  s.add_development_dependency "decidim-participatory_processes", Decidim.version
  s.add_development_dependency "decidim-assemblies", Decidim.version
  s.add_development_dependency "decidim-meetings", Decidim.version
  s.add_development_dependency "decidim-budgets", Decidim.version
end
