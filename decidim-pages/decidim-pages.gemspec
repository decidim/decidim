# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/pages/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Pages.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3"

  s.name = "decidim-pages"
  s.summary = "Decidim pages module"
  s.description = "A pages component for decidim's participatory processes."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  compatible_constraint = "#{Gem::Version.new(s.version).approximate_recommendation}.a"

  s.add_dependency "decidim-core", compatible_constraint

  s.add_development_dependency "decidim-dev", compatible_constraint
  s.add_development_dependency "decidim-participatory_processes", compatible_constraint
end
