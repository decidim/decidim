# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/forms/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Forms.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva", "Rubén González Valero"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com", "rbngzlv@gmail.com"]
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

  s.name = "decidim-forms"
  s.summary = "Decidim forms"
  s.description = "A forms gem for decidim."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Forms.version
  s.add_dependency "wicked_pdf", "~> 2.1"
  s.add_dependency "wkhtmltopdf-binary", "~> 0.12"

  s.add_development_dependency "decidim-admin", Decidim::Forms.version
  s.add_development_dependency "decidim-dev", Decidim::Forms.version
end
