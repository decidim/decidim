# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/consultations/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "decidim-consultations"
  s.summary = "Extends Decidim adding a first level public consultation component"
  s.description = s.summary
  s.version = Decidim::Consultations.version
  s.authors = ["Juan Salvador Perez Garcia"]
  s.email = ["jsperezg@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3.1"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", Decidim::Consultations.version
  s.add_dependency "decidim-comments", Decidim::Consultations.version
  s.add_dependency "decidim-core", Decidim::Consultations.version
  s.add_dependency "rails", "~> 5.1"

  s.add_development_dependency "decidim-dev", Decidim::Consultations.version
end
