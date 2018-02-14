# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = "0.10.0.pre"
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3"

  s.name = "decidim-proposals"
  s.summary = "Decidim proposals module"
  s.description = "A proposals component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-comments", s.version
  s.add_dependency "decidim-core", s.version
  s.add_dependency "kaminari", "~> 1.0"
  s.add_dependency "ransack", "~> 1.8"
  s.add_dependency "social-share-button", "~> 1.0"

  s.add_development_dependency "decidim-admin", s.version
  s.add_development_dependency "decidim-assemblies", s.version
  s.add_development_dependency "decidim-budgets", s.version
  s.add_development_dependency "decidim-dev", s.version
  s.add_development_dependency "decidim-meetings", s.version
  s.add_development_dependency "decidim-participatory_processes", s.version
end
