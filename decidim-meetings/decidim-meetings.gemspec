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

  s.name = "decidim-meetings"
  s.summary = "A meetings component for decidim's participatory processes."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim.version
  s.add_dependency "date_validator", "~> 0.9"
  s.add_dependency "searchlight", "~> 4.1.0"
  s.add_dependency "kaminari", "~> 1.0.1"
  s.add_dependency "httparty", "~> 0.15.0"
  s.add_dependency "jquery-tmpl-rails", "~> 1.1.0"
  s.add_dependency "icalendar", "~> 2.4.1"

  s.add_development_dependency "decidim-dev", Decidim.version
  s.add_development_dependency "decidim-admin", Decidim.version
  s.add_development_dependency "decidim-participatory_processes", Decidim.version
  s.add_development_dependency "decidim-assemblies", Decidim.version
  s.add_development_dependency "decidim-proposals", Decidim.version
  s.add_development_dependency "decidim-results", Decidim.version
end
