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

  s.name = "decidim-surveys"
  s.summary = "Decidim surveys module"
  s.description = "A surveys component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", s.version
  s.add_dependency "jquery-tmpl-rails", "~> 1.1"

  s.add_development_dependency "decidim-admin", s.version
  s.add_development_dependency "decidim-dev", s.version
  s.add_development_dependency "decidim-participatory_processes", s.version
end
