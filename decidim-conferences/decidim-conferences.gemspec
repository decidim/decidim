# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/conferences/version"

Gem::Specification.new do |s|
  s.version = Decidim::Conferences.version
  s.authors = ["Isaac Massot Gil"]
  s.email = ["isaac.mg@coditramuntana.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3"

  s.name = "decidim-conferences"
  s.summary = "Decidim conferences module"
  s.description = "Conferences component for decidim."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  compatible_constraint = "#{Gem::Version.new(s.version).approximate_recommendation}.a"

  s.add_dependency "decidim-core", compatible_constraint
  s.add_dependency "decidim-meetings", compatible_constraint

  s.add_development_dependency "decidim-admin", compatible_constraint
  s.add_development_dependency "decidim-dev", compatible_constraint
end
