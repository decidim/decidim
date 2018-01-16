# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "decidim-debates"
  s.summary     = "A debates component for decidim's participatory processes."
  s.description = s.summary
  s.version     = "0.0.1"
  s.authors     = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva", "Genís Matutes Pujol"]
  s.email       = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com", "genis.matutes@gmail.com"]

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core"
  s.add_dependency "decidim-comments"
  s.add_dependency "rectify", "~> 0.8"
  s.add_dependency "date_validator", "~> 0.9"
  s.add_dependency "searchlight", "~> 4.1.0"
  s.add_dependency "kaminari", "~> 1.0.0.rc1"

  s.add_development_dependency "decidim-dev"
end
