# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/comments/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Comments.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.6"

  s.name = "decidim-comments"
  s.summary = "Decidim comments module"
  s.description = "Pluggable comments system for some components."
  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Comments.version
  s.add_dependency "jquery-rails", "~> 4.3"
  s.add_dependency "redcarpet", "~> 3.4"

  s.add_development_dependency "decidim-admin", Decidim::Comments.version
  s.add_development_dependency "decidim-dev", Decidim::Comments.version
end
