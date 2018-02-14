# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  s.name = "decidim-verifications"
  s.version = "0.10.0.pre"
  s.authors = ["David Rodriguez"]
  s.email = ["deivid.rodriguez@riseup.net"]
  s.homepage = "https://github.com/decidim/decidim"

  s.summary = "Decidim verifications module"
  s.description = "Several verification methods for your decidim instance"
  s.license = "AGPL-3.0"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", s.version

  s.add_development_dependency "decidim-admin", s.version
  s.add_development_dependency "decidim-dev", s.version
end
