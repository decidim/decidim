$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  Decidim.add_default_gemspec_properties(s)

  s.name        = "decidim-pages"
  s.summary     = "A pages component for decidim's participatory processes."
  s.summary     = s.description

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim.version
  s.add_dependency "rectify", "~> 0.7.1"

  s.add_development_dependency "decidim-dev", Decidim.version
end
