# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'decidim-core/lib/decidim/core/version'

Gem::Specification.new do |spec|
  spec.name          = "decidim"
  spec.version       = Decidim.version
  spec.authors       = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
  spec.email         = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]

  spec.summary       = %q{Citizen participation framework for Ruby on Rails.}
  spec.description   = %q{Citizen participation framework for Ruby on Rails.}
  spec.homepage      = "https://github.com/codegram/decidim"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.required_ruby_version = '>= 2.3.1'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ['decidim']
  spec.require_paths = ["lib"]

  spec.add_dependency 'decidim-core'
  spec.add_dependency 'rails', Decidim.rails_version

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
