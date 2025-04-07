# frozen_string_literal: true

require "decidim/accountability/admin"
require "decidim/accountability/api"
require "decidim/accountability/engine"
require "decidim/accountability/admin_engine"
require "decidim/accountability/component"

module Decidim
  # Base module for this engine.
  module Accountability
    autoload :ResultSerializer, "decidim/accountability/result_serializer"

    include ActiveSupport::Configurable

    # Public Setting that defines whether proposals can be linked to meetings
    config_accessor :enable_proposal_linking do
      Decidim::Env.new("ACCOUNTABILITY_ENABLE_PROPOSAL_LINKING", Decidim.const_defined?("Proposals")).present?
    end
  end
end
