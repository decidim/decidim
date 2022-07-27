# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/proposals/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Proposals.version
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
  s.required_ruby_version = ">= 3.1"

  s.name = "decidim-proposals"
  s.summary = "Decidim proposals module"
  s.description = "A proposals component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-comments", Decidim::Proposals.version
  s.add_dependency "decidim-core", Decidim::Proposals.version
  s.add_dependency "doc2text", "~> 0.4.5"
  s.add_dependency "redcarpet", "~> 3.5", ">= 3.5.1"

  s.add_development_dependency "decidim-admin", Decidim::Proposals.version
  s.add_development_dependency "decidim-assemblies", Decidim::Proposals.version
  s.add_development_dependency "decidim-budgets", Decidim::Proposals.version
  s.add_development_dependency "decidim-dev", Decidim::Proposals.version
  s.add_development_dependency "decidim-meetings", Decidim::Proposals.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Proposals.version
end
