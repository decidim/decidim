# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/admin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Admin.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-admin"
  s.summary = "Organization administration"
  s.description = "Organization administration to manage a single organization."
  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Admin.version
  s.add_dependency "devise", "~> 4.2"
  s.add_dependency "devise-i18n", "~> 1.2.0"
  s.add_dependency "devise_invitable", "~> 1.7.0"
  s.add_dependency "sassc-rails", "~> 1.3.0"
  s.add_dependency "jquery-rails", "~> 4.3.1"
  s.add_dependency "foundation_rails_helper", "~> 3.0.0.rc"
  s.add_dependency "active_link_to", "~> 1.0.0"
  s.add_dependency "select2-rails", "~> 4.0.3"

  s.add_development_dependency "decidim-dev", Decidim::Admin.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Admin.version
end
