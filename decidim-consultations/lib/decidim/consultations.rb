# frozen_string_literal: true

require "decidim/consultations/admin"
require "decidim/consultations/api"
require "decidim/consultations/engine"
require "decidim/consultations/admin_engine"
require "decidim/consultations/participatory_space"

module Decidim
  # Base module for the consultations engine.
  module Consultations
    include ActiveSupport::Configurable

    # Sets the expiration time for the statistic data.
    config_accessor :stats_cache_expiration_time do
      5.minutes
    end
  end
end
