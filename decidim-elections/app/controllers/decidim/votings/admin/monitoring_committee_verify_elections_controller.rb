# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows a monitoring committee member to list and validate the polling stations closures.
      class MonitoringCommitteeVerifyElectionsController < Admin::ApplicationController
        include VotingAdmin

        helper_method :current_voting, :elections

        def index
          enforce_permission_to :read, :monitoring_committee_verify_elections, voting: current_voting
        end

        private

        def elections
          @elections = current_voting.published_elections
        end
      end
    end
  end
end
