# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/surveys/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Surveys.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-surveys"
  s.summary = "Decidim surveys module"
  s.description = "A surveys component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Surveys.version
  s.add_dependency "decidim-forms", Decidim::Surveys.version
  s.add_dependency "decidim-templates", Decidim::Surveys.version

  s.add_development_dependency "decidim-admin", Decidim::Surveys.version
  s.add_development_dependency "decidim-dev", Decidim::Surveys.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Surveys.version
end
