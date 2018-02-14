# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = "0.10.0.pre"
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3"

  s.name = "decidim-api"
  s.summary = "Decidim API module"
  s.description = "API engine for decidim"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "graphiql-rails", "~> 1.4"
  s.add_dependency "graphql", "~> 1.6"
  s.add_dependency "rack-cors", "~> 1.0"
  s.add_dependency "sprockets-es6", "~> 0.9.2"

  s.add_development_dependency "decidim-comments", s.version
  s.add_development_dependency "decidim-core", s.version
  s.add_development_dependency "decidim-dev", s.version
  s.add_development_dependency "decidim-participatory_processes", s.version
end
