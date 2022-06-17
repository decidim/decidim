# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/participatory_processes/version"

Gem::Specification.new do |s|
  s.version = Decidim::ParticipatoryProcesses.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = ">= 3.1"

  s.name = "decidim-participatory_processes"
  s.summary = "Decidim participatory processes module"
  s.description = "Participatory processes component for decidim."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::ParticipatoryProcesses.version

  s.add_development_dependency "decidim-admin", Decidim::ParticipatoryProcesses.version
  s.add_development_dependency "decidim-dev", Decidim::ParticipatoryProcesses.version
  s.add_development_dependency "decidim-meetings", Decidim::ParticipatoryProcesses.version
end
