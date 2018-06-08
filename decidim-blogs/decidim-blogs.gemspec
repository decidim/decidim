# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/blogs/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Blogs.version
  s.authors = ["Isaac Massot Gil"]
  s.email = ["isaac.mg@coditramuntana.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-blogs"
  s.summary = "Decidim blogs module"
  s.description = "A Blog component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  compatible_constraint = "#{Gem::Version.new(s.version).approximate_recommendation}.a"

  s.add_dependency "decidim-admin", compatible_constraint
  s.add_dependency "decidim-comments", compatible_constraint
  s.add_dependency "decidim-core", compatible_constraint
  s.add_dependency "httparty", "~> 0.16.0"
  s.add_dependency "jquery-tmpl-rails", "~> 1.1"
  s.add_dependency "kaminari", "~> 1.0"

  s.add_development_dependency "decidim-admin", compatible_constraint
  s.add_development_dependency "decidim-assemblies", compatible_constraint
  s.add_development_dependency "decidim-dev", compatible_constraint
  s.add_development_dependency "decidim-participatory_processes", compatible_constraint
end
