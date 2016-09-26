# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "decidim-admin"
  s.version     = Decidim.version
  s.authors     = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email       = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.homepage    = ""
  s.summary     = "Organization administration"
  s.description = "Organization administration to manage a single organization."
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

  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner", "~> 1.5.0"
  s.add_development_dependency "capybara", "~> 2.4"
  s.add_development_dependency "rspec-rails", "~> 3.5"
  s.add_development_dependency "byebug"
  s.add_development_dependency "wisper-rspec"
  s.add_development_dependency "pg"
  s.add_development_dependency "listen"
  s.add_development_dependency "launchy"
  s.add_development_dependency "i18n-tasks", "~> 0.9.5"
end
