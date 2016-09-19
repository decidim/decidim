# frozen_string_literal: true
require "decidim/core/engine"
require "decidim/core/version"
require "devise"

require "foundation-rails"

# Decidim configuration.
module Decidim
  @config = OpenStruct.new

  def self.setup
    yield(@config)
  end

  def self.config
    @config
  end
end
