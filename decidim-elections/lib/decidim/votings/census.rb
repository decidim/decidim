# frozen_string_literal: true

module Decidim
  module Votings
    # This module contains all the domain logic associated to Decidim's Votings
    # Census.
    module Census
      include ActiveSupport::Configurable

      # How long the census access codes export file will are available in the server
      config_accessor :census_access_codes_export_expiry_time do
        2.days
      end
    end
  end
end
