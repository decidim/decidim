# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/debates/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.version = Decidim::Debates.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva", "Genis Matutes Pujol"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com", "genis.matutes@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-debates"
  s.summary = "Decidim debates module"
  s.description = "A debates component for decidim's participatory spaces."
  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-comments", Decidim::Debates.version
  s.add_dependency "decidim-core", Decidim::Debates.version

  s.add_development_dependency "decidim-admin", Decidim::Debates.version
  s.add_development_dependency "decidim-dev", Decidim::Debates.version
end
