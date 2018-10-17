# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "decidim-core"
  s.version = Decidim::Core.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.homepage = "https://github.com/decidim/decidim"
  s.summary = "The core of the Decidim framework."
  s.description = "Adds core features so other engines can hook into the framework."
  s.license = "AGPL-3.0"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "active_link_to", "~> 1.0"
  s.add_dependency "autoprefixer-rails", "~> 8.0"
  s.add_dependency "batch-loader", "~> 1.2"
  s.add_dependency "carrierwave", "~> 1.1"
  s.add_dependency "cells-erb", "~> 0.1.0"
  s.add_dependency "cells-rails", "~> 0.0.9"
  s.add_dependency "date_validator", "~> 0.9.0"
  s.add_dependency "devise", "~> 4.3"
  s.add_dependency "devise-i18n", "~> 1.2"
  s.add_dependency "doorkeeper", "~> 4.4"
  s.add_dependency "doorkeeper-i18n", "~> 4.0"
  s.add_dependency "file_validators", "~> 2.1"
  s.add_dependency "foundation-rails", "~> 6.4", "< 6.5"
  s.add_dependency "foundation_rails_helper", "~> 3.0"
  s.add_dependency "geocoder", "~> 1.4"
  s.add_dependency "hashdiff", "~> 0.3.7"
  s.add_dependency "invisible_captcha", "~> 0.10.0"
  s.add_dependency "jquery-rails", "~> 4.3"
  s.add_dependency "kaminari", "~> 1.0"
  s.add_dependency "loofah", "~> 2.0", ">= 2.2.1" # version 2.2.0 has a vulnerability
  s.add_dependency "mini_magick", "~> 4.8"
  s.add_dependency "nobspw", "~> 0.4.0"
  s.add_dependency "omniauth", "~> 1.6"
  s.add_dependency "omniauth-facebook", "~> 4.0"
  s.add_dependency "omniauth-google-oauth2", "~> 0.5.0"
  s.add_dependency "omniauth-twitter", "~> 1.4"
  s.add_dependency "paper_trail", "~> 9.0"
  s.add_dependency "pg", ">= 0.18", "< 2"
  s.add_dependency "pg_search", "~> 2.1", ">= 2.1.0"
  s.add_dependency "premailer-rails", "~> 1.9"
  s.add_dependency "rack-attack", "~> 5.2"
  s.add_dependency "rails", ">= 5.2", "< 6.0.x"
  s.add_dependency "rails-i18n", "~> 5.0"
  s.add_dependency "rectify", "~> 0.11.0"
  s.add_dependency "redis", "~> 4.0"
  s.add_dependency "rubyzip", "~> 1.2", ">= 1.2.2"
  s.add_dependency "sassc", "~> 1.12", ">= 1.12.1"
  s.add_dependency "sassc-rails", "~> 1.3"
  s.add_dependency "spreadsheet", "~> 1.1"
  s.add_dependency "sprockets-es6", "~> 0.9.2"
  s.add_dependency "truncato", "~> 0.7.10"
  s.add_dependency "uglifier", "~> 4.0"
  s.add_dependency "valid_email2", "~> 2.1"
  s.add_dependency "wisper", "~> 2.0"

  s.add_dependency "decidim-api", Decidim::Core.version

  s.add_development_dependency "decidim-dev", Decidim::Core.version
end
