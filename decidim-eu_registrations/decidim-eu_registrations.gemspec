# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/eu_registrations/version"

Gem::Specification.new do |s|
  s.version = Decidim::EuRegistrations.version
  s.authors = ["Cristian Georgescu"]
  s.email = ["georgescu.cristi@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-eu_registrations"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-eu_registrations"
  s.summary = "A decidim eu_registrations module"
  s.description = "EU Registration."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::EuRegistrations.version
end
