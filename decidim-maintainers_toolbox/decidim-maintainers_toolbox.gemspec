# frozen_string_literal: true

require_relative "lib/decidim/maintainers_toolbox/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-maintainers_toolbox"
  spec.version = Decidim::MaintainersToolbox::VERSION
  spec.authors = ["Andrés Pereira de Lucena"]
  spec.email = ["andreslucena@gmail.com"]

  spec.summary = "Release related tools for the Decidim project"
  spec.description = "Tools for releasing, backporting, changelog generating, and working with GitHub"

  spec.license = "AGPL-3.0"
  spec.homepage = "https://decidim.org"
  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  spec.required_ruby_version = ">= 2.7.5"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(
                        exe/
                        lib/
                        README.md
                      ))
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 1.10"
  spec.add_dependency "ruby-progressbar", "~> 1.7"
  spec.add_dependency "thor", "~> 1.0"

  spec.add_development_dependency "activesupport", "~> 6.1.7"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.18"
end
