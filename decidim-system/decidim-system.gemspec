# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "decidim-system"
  s.version     = Decidim.version
  s.authors     = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email       = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.homepage    = ""
  s.summary     = "System administration"
  s.description = "System administration to create new organization in an installation."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "decidim-core"
  s.add_dependency "rails", Decidim.rails_version
  s.add_dependency "devise", "~> 4.2"
  s.add_dependency "rectify", "~> 0.6"
  s.add_dependency "devise_invitable", "~> 1.7.0"
  s.add_dependency "foundation-rails", "~> 6.2.3.0"
  s.add_dependency "sass-rails", "~> 5.0.0"
  s.add_dependency "jquery-rails", "~> 4.0"
  s.add_dependency "turbolinks", Decidim.rails_version
  s.add_dependency "jquery-turbolinks", "~> 2.1.0"
  s.add_dependency "jbuilder", "~> 2.5"
  s.add_dependency "foundation_rails_helper", "~> 2.0.0"
  s.add_dependency "active_link_to", "~> 1.0.0"

  s.add_development_dependency "decidim-dev"
end
