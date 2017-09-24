# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-api"
  s.summary = "API engine for decidim"
  s.description = "API engine for decidim"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "graphql", "~> 1.6.0"
  s.add_dependency "graphiql-rails", "~> 1.4.2"
  s.add_dependency "rack-cors", "~> 1.0.1"
  s.add_dependency "sprockets-es6", "~> 0.9.2"

  s.add_development_dependency "decidim-dev", Decidim.version
  s.add_development_dependency "decidim-core", Decidim.version
  s.add_development_dependency "decidim-participatory_processes", Decidim.version
  s.add_development_dependency "decidim-comments", Decidim.version
end
