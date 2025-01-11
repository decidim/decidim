# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/initiatives/version"

Gem::Specification.new do |s|
  s.version = Decidim::Initiatives.version
  s.authors = ["Juan Salvador Perez Garcia"]
  s.email = ["jsperezg@gmail.com"]
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

  s.name = "decidim-initiatives"
  s.summary = "Decidim initiatives module"
  s.description = "Participants initiatives plugin for decidim."

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ Rakefile README.md))
    end
  end

  s.add_dependency "decidim-admin", Decidim::Initiatives.version
  s.add_dependency "decidim-comments", Decidim::Initiatives.version
  s.add_dependency "decidim-core", Decidim::Initiatives.version
  s.add_dependency "decidim-verifications", Decidim::Initiatives.version

  s.add_development_dependency "decidim-dev", Decidim::Initiatives.version
  s.add_development_dependency "decidim-meetings", Decidim::Initiatives.version
end
