# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows a monitoring committee member to list and validate the polling stations closures.
      class MonitoringCommitteeElectionResultsController < Admin::ApplicationController
        include VotingAdmin

        helper_method :current_voting, :elections, :election, :polling_stations

        def index
          enforce_permission_to :read, :monitoring_committee_election_results, voting: current_voting

          redirect_to voting_monitoring_committee_election_result_path(current_voting, elections.first) if elections.one?
        end

        def show
          enforce_permission_to :read, :monitoring_committee_election_results, voting: current_voting, election: election
        end

        private

        def polling_stations
          @polling_stations ||= current_voting.polling_stations
        end

        def elections
          @elections = current_voting.finished_elections
        end

        def election
          @election = elections.find(id: params[:id]).first
        end
      end
    end
  end
end
