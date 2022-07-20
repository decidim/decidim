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
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-pages"
  s.summary = "Decidim pages module"
  s.description = "A pages component for decidim's participatory processes."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Pages.version

  s.add_development_dependency "decidim-dev", Decidim::Pages.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Pages.version
end
