# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative "decidim-core/lib/decidim/core/version"

Gem::Specification.new do |spec|
  spec.version = Decidim.version
  spec.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  spec.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  spec.license = "AGPL-3.0"
  spec.homepage = "https://github.com/decidim/decidim"
  spec.required_ruby_version = ">= 2.3.1"

  spec.name = "decidim"

  spec.summary = "Citizen participation framework for Ruby on Rails."
  spec.description = "Citizen participation framework for Ruby on Rails."

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^decidim-/}) }
  spec.bindir = "bin"
  spec.executables = ["decidim"]
  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-core", Decidim.version
  spec.add_dependency "decidim-participatory_processes", Decidim.version
  spec.add_dependency "decidim-system", Decidim.version
  spec.add_dependency "decidim-admin", Decidim.version
  spec.add_dependency "decidim-api", Decidim.version
  spec.add_dependency "decidim-pages", Decidim.version
  spec.add_dependency "decidim-comments", Decidim.version
  spec.add_dependency "decidim-meetings", Decidim.version
  spec.add_dependency "decidim-proposals", Decidim.version
  spec.add_dependency "decidim-results", Decidim.version
  spec.add_dependency "decidim-budgets", Decidim.version
  spec.add_dependency "decidim-surveys", Decidim.version

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 12.0.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
