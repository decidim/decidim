# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows a monitoring committee member to list and validate the polling stations closures.
      class MonitoringCommitteePollingStationClosuresController < Admin::ApplicationController
        include VotingAdmin
        include Decidim::MonitoringCommitteePollingStationClosures::Admin::Filterable

        helper_method :current_voting, :closure, :elections, :election, :filtered_polling_stations

        def index
          enforce_permission_to :read, :monitoring_committee_polling_station_closures, voting: current_voting

          redirect_to voting_monitoring_committee_polling_station_closures_path(current_voting, election_id: elections.first.id) if elections.one? && params[:election_id].blank?
        end

        def show
          enforce_permission_to :read, :monitoring_committee_polling_station_closure, voting: current_voting, closure:
        end

        def edit
          enforce_permission_to :validate, :monitoring_committee_polling_station_closure, voting: current_voting, closure: closure

          @form = form(MonitoringCommitteePollingStationClosureForm).from_model(closure)
        end

        def validate
          enforce_permission_to :validate, :monitoring_committee_polling_station_closure, voting: current_voting, closure: closure

          @form = form(MonitoringCommitteePollingStationClosureForm).from_params(params)

          MonitoringCommitteeValidatePollingStationClosure.call(@form, closure) do
            on(:ok) do
              flash[:notice] = t(".success")
            end

            on(:invalid) do
              flash[:alert] = t(".error")
            end
          end

          redirect_to voting_monitoring_committee_polling_station_closures_path(current_voting, election_id: closure.election.id)
        end

        private

        def polling_stations
          @polling_stations ||= current_voting.polling_stations
        end

        def elections
          @elections = current_voting.published_elections
        end

        def election
          elections.find { |e| e.id == params[:election_id].to_i } if params[:election_id].present?
        end

        def closure
          @closure ||= Decidim::Votings::PollingStationClosure.find(params[:id])
        end

        def filtered_polling_stations
          filtered_collection.distinct
        end

        alias collection polling_stations
      end
    end
  end
end
