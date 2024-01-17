# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/consultations/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Consultations.version
  s.authors = ["Juan Salvador Perez Garcia"]
  s.email = ["jsperezg@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = "~> 3.0.0"

  s.name = "decidim-consultations"
  s.summary = "Decidim consultations module"
  s.description = "Extends Decidim adding a first level public consultation component"

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ Rakefile README.md))
    end
  end

  s.add_dependency "decidim-admin", Decidim::Consultations.version
  s.add_dependency "decidim-comments", Decidim::Consultations.version
  s.add_dependency "decidim-core", Decidim::Consultations.version

  s.add_development_dependency "decidim-dev", Decidim::Consultations.version
end
