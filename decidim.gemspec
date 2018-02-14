# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.version = "0.10.0.pre"
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.3"

  s.name = "decidim"

  s.summary = "Citizen participation framework for Ruby on Rails."
  s.description = "A generator and multiple gems made with Ruby on Rails."

  s.files = Dir[
    "{docs,lib}/**/*",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  s.bindir = "bin"
  s.executables = ["decidim"]
  s.require_paths = ["lib"]

  s.add_dependency "decidim-accountability", s.version
  s.add_dependency "decidim-admin", s.version
  s.add_dependency "decidim-api", s.version
  s.add_dependency "decidim-assemblies", s.version
  s.add_dependency "decidim-budgets", s.version
  s.add_dependency "decidim-comments", s.version
  s.add_dependency "decidim-core", s.version
  s.add_dependency "decidim-debates", s.version
  s.add_dependency "decidim-meetings", s.version
  s.add_dependency "decidim-pages", s.version
  s.add_dependency "decidim-participatory_processes", s.version
  s.add_dependency "decidim-proposals", s.version
  s.add_dependency "decidim-surveys", s.version
  s.add_dependency "decidim-system", s.version
  s.add_dependency "decidim-verifications", s.version

  s.add_development_dependency "bundler", "~> 1.12"
  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
