$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  Decidim.add_default_gemspec_properties(s)

  s.name        = "decidim-meetings"
  s.summary     = "A meetings component for decidim's participatory processes."
  s.description = s.description

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim.version
  s.add_dependency "rectify", "~> 0.8"
  s.add_dependency "date_validator", "~> 0.9"
  s.add_dependency "searchlight", "~> 4.1.0"
  s.add_dependency "kaminari", "~> 1.0.1"
  s.add_dependency "geocoder", "~> 1.4.1"
  s.add_dependency "httparty", "~> 0.14.0"
  s.add_dependency "jquery-tmpl-rails", "~> 1.1.0"

  s.add_development_dependency "decidim-dev", Decidim.version
  s.add_development_dependency "decidim-proposals", Decidim.version
  s.add_development_dependency "decidim-admin", Decidim.version
  s.add_development_dependency "webmock", "~> 2.3.2"
end
