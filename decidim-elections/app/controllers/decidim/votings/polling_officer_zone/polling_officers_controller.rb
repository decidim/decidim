# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Exposes the polling officer zone for polling officer users
      class PollingOfficersController < Decidim::Votings::PollingOfficerZone::ApplicationController
        def show
          enforce_permission_to :view, :polling_officer, polling_officer: polling_officer
        end
      end
    end
  end
end
