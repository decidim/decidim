# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  version = "0.32.0.dev"
  s.version = version
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
  s.required_ruby_version = "~> 3.4.0"

  s.name = "decidim"

  s.summary = "Citizen participation framework for Ruby on Rails."
  s.description = "A generator and multiple gems made with Ruby on Rails."

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(
                        docs/
                        lib/
                        LICENSE-AGPLv3.txt
                        Rakefile
                        README.md
                        package.json
                        package-lock.json
                        packages/
                        babel.config.json
                        decidim-core/lib/decidim/shakapacker/
                      ))
    end
  end

  s.require_paths = ["lib"]

  s.add_dependency "decidim-accountability", version
  s.add_dependency "decidim-admin", version
  s.add_dependency "decidim-api", version
  s.add_dependency "decidim-assemblies", version
  s.add_dependency "decidim-blogs", version
  s.add_dependency "decidim-budgets", version
  s.add_dependency "decidim-comments", version
  s.add_dependency "decidim-core", version
  s.add_dependency "decidim-debates", version
  s.add_dependency "decidim-forms", version
  s.add_dependency "decidim-generators", version
  s.add_dependency "decidim-meetings", version
  s.add_dependency "decidim-pages", version
  s.add_dependency "decidim-participatory_processes", version
  s.add_dependency "decidim-proposals", version
  s.add_dependency "decidim-surveys", version
  s.add_dependency "decidim-system", version
  s.add_dependency "decidim-verifications", version

  s.add_development_dependency "bundler", "~> 2.2", ">= 2.2.18"
  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
