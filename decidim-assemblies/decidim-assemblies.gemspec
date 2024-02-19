# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/assemblies/version"

Gem::Specification.new do |s|
  s.version = Decidim::Assemblies.version
  s.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  s.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim"
  s.required_ruby_version = "~> 3.0.0"

  s.name = "decidim-assemblies"
  s.summary = "Decidim assemblies module"
  s.description = "Assemblies component for decidim."

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ Rakefile README.md))
    end
  end

  s.add_dependency "decidim-core", Decidim::Assemblies.version

  s.add_development_dependency "decidim-admin", Decidim::Assemblies.version
  s.add_development_dependency "decidim-dev", Decidim::Assemblies.version
  s.add_development_dependency "decidim-meetings", Decidim::Assemblies.version
  s.add_development_dependency "decidim-proposals", Decidim::Assemblies.version
end
