# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Exposes the polling officer zone for polling officer users
      class PollingOfficersController < Decidim::Votings::PollingOfficerZone::ApplicationController
        helper Decidim::Admin::IconLinkHelper
        helper Decidim::ResourceHelper

        helper_method :polling_stations, :polling_officers_elections

        def index
          enforce_permission_to :view, :polling_officers, polling_officers: polling_officers
        end

        private

        def polling_officers_elections
          spaces = polling_officers.flat_map(&:voting)
          component_ids = spaces.flat_map { |space| space.components.where(manifest_name: "elections").published.pluck(:id) }

          Decidim::Elections::Election.where(decidim_component_id: component_ids)
        end
      end
    end
  end
end
