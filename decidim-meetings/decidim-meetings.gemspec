# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/meetings/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Meetings.version
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

  s.name = "decidim-meetings"
  s.summary = "Decidim meetings module"
  s.description = "A meetings component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Meetings.version
  s.add_dependency "decidim-forms", Decidim::Meetings.version
  s.add_dependency "icalendar", "~> 2.5"

  s.add_development_dependency "decidim-admin", Decidim::Meetings.version
  s.add_development_dependency "decidim-assemblies", Decidim::Meetings.version
  s.add_development_dependency "decidim-dev", Decidim::Meetings.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Meetings.version
end
