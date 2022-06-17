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
  s.required_ruby_version = ">= 3.1"

  s.name = "decidim-blogs"
  s.summary = "Decidim blogs module"
  s.description = "A Blog component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", Decidim::Blogs.version
  s.add_dependency "decidim-comments", Decidim::Blogs.version
  s.add_dependency "decidim-core", Decidim::Blogs.version

  s.add_development_dependency "decidim-admin", Decidim::Blogs.version
  s.add_development_dependency "decidim-assemblies", Decidim::Blogs.version
  s.add_development_dependency "decidim-dev", Decidim::Blogs.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Blogs.version
end
