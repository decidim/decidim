# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/elections/version"

Gem::Specification.new do |s|
  s.version = Decidim::Elections.version
  s.authors = ["Leonardo Diez"]
  s.email = ["leo@codegram.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-elections"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-elections"
  s.summary = "A decidim elections module"
  s.description = "The Elections module adds elections to any participatory space."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Elections.version

  s.add_development_dependency "decidim-admin", Decidim::Elections.version
  s.add_development_dependency "decidim-dev", Decidim::Elections.version
end
