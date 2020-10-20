# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/demographics/version"

Gem::Specification.new do |s|
  s.version = Decidim::Demographics.version
  s.authors = [""]
  s.email = [""]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-demographics"
  s.required_ruby_version = ">= 2.6"

  s.name = "decidim-demographics"
  s.summary = "A decidim demographics module"
  s.description = "Module that collects demographic data about users."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Demographics.version
end
