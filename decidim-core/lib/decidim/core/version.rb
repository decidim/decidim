# frozen_string_literal: true
# This holds Decidim's version and the Rails version on which it depends.
module Decidim
  def self.version
    "0.1.0.alpha"
  end

  def self.rails_version
    "~> 5.0.0"
  end
end
