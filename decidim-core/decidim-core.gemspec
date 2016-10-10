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
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", Decidim.rails_version
  s.add_dependency "devise", "~> 4.2"
  s.add_dependency "devise-i18n", "~> 1.1.0"
  s.add_dependency "rectify", "~> 0.6"
  s.add_dependency "foundation-rails", "~> 6.2.3.0"
  s.add_dependency "sass-rails", "~> 5.0.0"
  s.add_dependency "jquery-rails", "~> 4.0"
  s.add_dependency "turbolinks", Decidim.rails_version
  s.add_dependency "jquery-turbolinks", "~> 2.1.0"
  s.add_dependency "jbuilder", "~> 2.5"
  s.add_dependency "foundation_rails_helper", "~> 2.0.0"
  s.add_dependency "active_link_to", "~> 1.0.0"
  s.add_dependency "pg", "~> 0.19.0"
  s.add_dependency "redis", "~> 3.3.0"

  s.add_development_dependency "decidim-dev", Decidim.version
end
