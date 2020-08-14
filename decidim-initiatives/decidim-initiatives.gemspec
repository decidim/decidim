# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/initiatives/version"

Gem::Specification.new do |s|
  s.version = Decidim::Initiatives.version
  s.authors = ["Juan Salvador Perez Garcia"]
  s.email = ["jsperezg@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.6"

  s.name = "decidim-initiatives"
  s.summary = "Decidim initiatives module"
  s.description = "Citizen initiatives plugin for decidim."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", Decidim::Initiatives.version
  s.add_dependency "decidim-comments", Decidim::Initiatives.version
  s.add_dependency "decidim-core", Decidim::Initiatives.version
  s.add_dependency "decidim-verifications", Decidim::Initiatives.version
  s.add_dependency "kaminari", "~> 1.2", ">= 1.2.1"
  s.add_dependency "origami", "~> 2.1"
  s.add_dependency "virtus-multiparams", "~> 0.1"
  s.add_dependency "wicked", "~> 1.3"
  s.add_dependency "wicked_pdf", "~> 1.4"
  s.add_dependency "wkhtmltopdf-binary", "~> 0.12"

  s.add_development_dependency "decidim-dev", Decidim::Initiatives.version
end
