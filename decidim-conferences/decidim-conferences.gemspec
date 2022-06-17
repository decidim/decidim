# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/conferences/version"

Gem::Specification.new do |s|
  s.version = Decidim::Conferences.version
  s.authors = ["Isaac Massot Gil"]
  s.email = ["isaac.mg@coditramuntana.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 3.1"

  s.name = "decidim-conferences"
  s.summary = "Decidim conferences module"
  s.description = "Conferences component for decidim."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Conferences.version
  s.add_dependency "decidim-meetings", Decidim::Conferences.version
  s.add_dependency "wicked_pdf", "~> 2.1"
  s.add_dependency "wkhtmltopdf-binary", "~> 0.12"

  s.add_development_dependency "decidim-admin", Decidim::Conferences.version
  s.add_development_dependency "decidim-dev", Decidim::Conferences.version
end
