# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require_relative "../decidim-core/lib/decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  Decidim.add_default_gemspec_properties(s)

  s.name        = "decidim-comments"
  s.summary     = "Pluggable comments system for some components."
  s.description = "Pluggable comments system for some components."
  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim.version
  s.add_dependency "rails", *Decidim.rails_version
  s.add_dependency "foundation-rails", "~> 6.2.4.0"
  s.add_dependency "sass-rails", "~> 5.0.0"
  s.add_dependency "jquery-rails", "~> 4.0"
  s.add_dependency "turbolinks", *Decidim.rails_version
  s.add_dependency "foundation_rails_helper", "~> 2.0.0"
  s.add_dependency "react-rails", "~> 1.9.0"

  s.add_development_dependency "decidim-dev", Decidim.version
end
