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
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-admin"
  s.summary = "Decidim organization administration"
  s.description = "Organization administration to manage a single organization."
  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "active_link_to", "~> 1.0"
  s.add_dependency "decidim-core", Decidim::Admin.version
  s.add_dependency "devise", "~> 4.7"
  s.add_dependency "devise-i18n", "~> 1.2"
  s.add_dependency "devise_invitable", "~> 2.0"

  s.add_development_dependency "decidim-dev", Decidim::Admin.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Admin.version
end
