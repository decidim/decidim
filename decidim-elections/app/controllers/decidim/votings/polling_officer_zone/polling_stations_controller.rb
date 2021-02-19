# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Space to manage the elections for a Polling Station Officer
      class PollingStationsController < Decidim::Votings::PollingOfficerZone::ApplicationController
        helper_method :polling_station

        def show
          enforce_permission_to :view, :polling_station, polling_officers: polling_officers
        end

        private

        def polling_station
          @polling_station ||= Decidim::Votings::PollingStation.find(params[:id])
        end
      end
    end
  end
end
