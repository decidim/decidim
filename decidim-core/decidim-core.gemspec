# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "decidim-core"
  s.version     = Decidim.version
  s.authors     = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email       = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.homepage    = ""
  s.summary     = "The core of the Decidim framework."
  s.description = "Adds core features so other engines can hook into the framework."
  s.license     = "AGPLv3"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  s.add_dependency "rails", *Decidim.rails_version
  s.add_dependency "devise", "~> 4.2"
  s.add_dependency "devise-i18n", "~> 1.1.0"
  s.add_dependency "rectify", "~> 0.8.0"
  s.add_dependency "sassc-rails", "~> 1.3.0"
  s.add_dependency "foundation-rails", "~> 6.3.0.0"
  s.add_dependency "jquery-rails", "~> 4.2.2"
  s.add_dependency "carrierwave", "~> 1.0.0"
  s.add_dependency "foundation_rails_helper", "~> 3.0.0.rc"
  s.add_dependency "active_link_to", "~> 1.0.0"
  s.add_dependency "pg", "~> 0.19.0"
  s.add_dependency "redis", "~> 3.3.0"
  s.add_dependency "roadie-rails", "~> 1.0"
  s.add_dependency "roadie", "~> 3.2.1"
  s.add_dependency "high_voltage", "~> 3.0.0"
  s.add_dependency "date_validator", "~> 0.9.0"
  s.add_dependency "sprockets-es6", "~> 0.9.2"
  s.add_dependency "cancancan", "~> 1.15.0"
  s.add_dependency "truncato", "~> 0.7.9"
  s.add_dependency "mini_magick", "~> 4.6.0"
  s.add_dependency "file_validators", "~> 2.1.0"
  s.add_dependency "omniauth", "~> 1.3.1"
  s.add_dependency "omniauth-facebook", "~> 4.0.0"
  s.add_dependency "omniauth-twitter", "~> 1.3.0"
  s.add_dependency "omniauth-google-oauth2", "~> 0.4.1"

  s.add_dependency "decidim-api", Decidim.version

  s.add_development_dependency "decidim-dev", Decidim.version
end
