# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/meetings/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Meetings.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-meetings"
  s.summary = "Decidim meetings module"
  s.description = "A meetings component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "cells-erb", "~> 0.1.0"
  s.add_dependency "cells-rails", "~> 0.0.9"
  s.add_dependency "decidim-core", Decidim::Meetings.version
  s.add_dependency "decidim-forms", Decidim::Meetings.version
  s.add_dependency "httparty", "~> 0.17"
  s.add_dependency "icalendar", "~> 2.5"
  s.add_dependency "jquery-tmpl-rails", "~> 1.1"
  s.add_dependency "kaminari", "~> 1.2", ">= 1.2.1"
  s.add_dependency "searchlight", "~> 4.1"

  s.add_development_dependency "decidim-admin", Decidim::Meetings.version
  s.add_development_dependency "decidim-assemblies", Decidim::Meetings.version
  s.add_development_dependency "decidim-dev", Decidim::Meetings.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Meetings.version
end
