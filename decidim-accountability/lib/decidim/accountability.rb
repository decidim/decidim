# frozen_string_literal: true

require "decidim/accountability/admin"
require "decidim/accountability/engine"
require "decidim/accountability/admin_engine"
require "decidim/accountability/component"
require "decidim/accountability/api"

module Decidim
  # Base module for this engine.
  module Accountability
    autoload :ResultSerializer, "decidim/accountability/result_serializer"
  end
end
