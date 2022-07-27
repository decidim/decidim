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
          enforce_permission_to :view, :polling_officers, polling_officers:
        end

        private

        def polling_officers_elections
          @polling_officers_elections ||= polling_officers.flat_map { |polling_officer| polling_officer.voting.published_elections }
        end
      end
    end
  end
end
