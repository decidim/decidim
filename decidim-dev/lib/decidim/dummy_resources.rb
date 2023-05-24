# frozen_string_literal: true

require "decidim/dummy_resources/admin"
require "decidim/dummy_resources/engine"
require "decidim/dummy_resources/admin_engine"
require "decidim/dummy_resources/component"

module Decidim
  module DummyResources
    include ActiveSupport::Configurable

    # Settings needed to compare emendations in Decidim::SimilarEmendations
    config_accessor :similarity_threshold do
      0.25
    end
    config_accessor :similarity_limit do
      10
    end
  end
end
