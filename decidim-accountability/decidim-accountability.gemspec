# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/accountability/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Accountability.version
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

  s.name = "decidim-accountability"
  s.summary = "Decidim accountability module"
  s.description = "An accountability component for decidim's participatory spaces."

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ Rakefile README.md))
    end
  end

  s.add_dependency "decidim-comments", Decidim::Accountability.version
  s.add_dependency "decidim-core", Decidim::Accountability.version

  s.add_development_dependency "decidim-admin", Decidim::Accountability.version
  s.add_development_dependency "decidim-assemblies", Decidim::Accountability.version
  s.add_development_dependency "decidim-comments", Decidim::Accountability.version
  s.add_development_dependency "decidim-dev", Decidim::Accountability.version
  s.add_development_dependency "decidim-meetings", Decidim::Accountability.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Accountability.version
  s.add_development_dependency "decidim-proposals", Decidim::Accountability.version
end
