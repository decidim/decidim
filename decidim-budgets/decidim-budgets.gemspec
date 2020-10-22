# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/budgets/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Budgets.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-budgets"
  s.summary = "Decidim budgets module"
  s.description = "A budgets component for decidim's participatory spaces."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-comments", Decidim::Budgets.version
  s.add_dependency "decidim-core", Decidim::Budgets.version
  s.add_dependency "kaminari", "~> 1.2", ">= 1.2.1"
  s.add_dependency "searchlight", "~> 4.1"

  s.add_development_dependency "decidim-admin", Decidim::Budgets.version
  s.add_development_dependency "decidim-dev", Decidim::Budgets.version
  s.add_development_dependency "decidim-proposals", Decidim::Budgets.version
end
