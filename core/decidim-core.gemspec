$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "decidim/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "decidim-core"
  s.version     = Decidim.version
  s.authors     = ["Josep Jaume Rey Peroy"]
  s.email       = ["josepjaume@gmail.com"]
  s.homepage    = ""
  s.summary     = "Summary of Decidim."
  s.description = "Description of Decidim."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"
  s.add_dependency "devise"
end
