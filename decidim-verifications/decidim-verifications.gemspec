# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/verifications/version"

Gem::Specification.new do |s|
  s.name = "decidim-verifications"
  s.version = Decidim::Verifications.version
  s.authors = ["David Rodriguez"]
  s.email = ["deivid.rodriguez@riseup.net"]
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 3.1"

  s.summary = "Decidim verifications module"
  s.description = "Several verification methods for your decidim instance"
  s.license = "AGPL-3.0"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Verifications.version

  s.add_development_dependency "decidim-admin", Decidim::Verifications.version
  s.add_development_dependency "decidim-dev", Decidim::Verifications.version
end
