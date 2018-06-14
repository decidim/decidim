# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/sortitions/version"

Gem::Specification.new do |s|
  s.version = Decidim::Sortitions.version
  s.authors = ["Juan Salvador Perez Garcia"]
  s.email = ["jsperezg@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-sortitions"
  s.summary = "Decidim sortitions module"
  s.description = "This module makes possible to select amont a set of proposal by sortition"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  compatible_constraint = "#{Gem::Version.new(s.version).approximate_recommendation}.a"

  s.add_dependency "decidim-admin", compatible_constraint
  s.add_dependency "decidim-comments", compatible_constraint
  s.add_dependency "decidim-core", compatible_constraint
  s.add_dependency "decidim-proposals", compatible_constraint
  s.add_dependency "social-share-button", "~> 1.0"

  s.add_development_dependency "decidim-dev", compatible_constraint
end
