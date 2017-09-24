# frozen_string_literal: true

# This holds Decidim's version and the Rails version on which it depends.
module Decidim
  def self.version
    "0.7.0-pre"
  end

  def self.rails_version
    ["~> 5.1.3"]
  end

  def self.faker_version
    "~> 1.8.4"
  end

  def self.add_default_gemspec_properties(spec)
    spec.version = Decidim.version
    spec.authors = ["Josep Jaume Rey Peroy", "Marc Riera Casals", "Oriol Gual Oliva"]
    spec.email = ["josepjaume@gmail.com", "mrc2407@gmail.com", "oriolgual@gmail.com"]
    spec.license = "AGPL-3.0"
    spec.homepage = "https://github.com/decidim/decidim"
    spec.required_ruby_version = ">= 2.3.1"
  end
end
