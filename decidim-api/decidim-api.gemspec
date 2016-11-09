# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "decidim-api"
  s.version     = Decidim.version
  s.authors     = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email       = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.homepage    = "http://github.com/AjuntamentdeBarcelona/decidim"
  s.summary     = "API engine for decidim"
  s.description = "API engine for decidim"
  s.license     = "AGPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim.version
  s.add_dependency "rails", *Decidim.rails_version
  s.add_dependency "graphql", "~> 1.2.1"
  s.add_dependency "graphiql-rails", "~> 1.3.0"
  s.add_dependency "rack-cors", "~> 0.4.0"

  s.add_development_dependency "decidim-dev", Decidim.version
end
