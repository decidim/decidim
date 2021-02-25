# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Exposes the polling officer zone for polling officer users
      class PollingOfficersController < Decidim::Votings::PollingOfficerZone::ApplicationController
        helper Decidim::Admin::IconLinkHelper
        helper_method :polling_stations

        def show
          enforce_permission_to :view, :polling_officers, polling_officers: polling_officers
        end
      end
    end
  end
end
