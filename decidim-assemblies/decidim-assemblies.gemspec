# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/assemblies/version"

Gem::Specification.new do |s|
  s.version = Decidim::Assemblies.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-assemblies"
  s.summary = "Decidim assemblies module"
  s.description = "Assemblies component for decidim."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Assemblies.version

  s.add_development_dependency "decidim-admin", Decidim::Assemblies.version
  s.add_development_dependency "decidim-dev", Decidim::Assemblies.version
end
