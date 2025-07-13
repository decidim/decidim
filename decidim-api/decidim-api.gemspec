# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Api.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0-or-later"
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = "~> 3.3.0"

  s.name = "decidim-api"
  s.summary = "Decidim API module"
  s.description = "API engine for decidim"

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ docs/ lib/ Rakefile README.md))
    end
  end

  s.add_dependency "decidim-core", Decidim::Api.version
  s.add_dependency "devise-jwt", "~> 0.12.1"
  s.add_dependency "graphql", "~> 2.4.0"
  s.add_dependency "graphql-docs", "~> 5.0"
  s.add_dependency "rack-cors", "~> 1.0"

  s.add_development_dependency "decidim-assemblies", Decidim::Api.version
  s.add_development_dependency "decidim-comments", Decidim::Api.version
  s.add_development_dependency "decidim-dev", Decidim::Api.version
  s.add_development_dependency "decidim-participatory_processes", Decidim::Api.version
end
