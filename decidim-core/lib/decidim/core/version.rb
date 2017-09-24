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
end
