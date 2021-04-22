# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Space to manage the election closure of a Polling Station
      class ClosuresController < Decidim::Votings::PollingOfficerZone::ApplicationController
        helper_method :election, :polling_officer, :polling_station, :closure

        def show
          enforce_permission_to :manage, :polling_station_results, polling_officer: polling_officer
        end

        def new
          enforce_permission_to :manage, :polling_station_results, polling_officer: polling_officer

          @form = EnvelopesResultForm.new(
            polling_station_id: polling_station.id,
            election_id: election.id,
            election_votes_count: polling_station_election_votes_count
          )
        end

        def create
          enforce_permission_to :manage, :polling_station_results, polling_officer: polling_officer
          @form = form(EnvelopesResultForm).from_params(params).with_context(polling_officer: polling_officer)

          CreatePollingStationClosure.call(@form) do
            on(:ok) do
              flash[:notice] = t(".success")
              redirect_to edit_polling_officer_election_closure_path(polling_officer, election)
            end

            on(:invalid) do
              flash[:alert] = t(".error")

              render :new
            end
          end
        end

        def edit
          enforce_permission_to :manage, :polling_station_results, polling_officer: polling_officer

          @form = form(ClosureResultForm).from_model(closure)
        end

        def update
          enforce_permission_to :manage, :polling_station_results, polling_officer: polling_officer
          @form = form(ClosureResultForm).from_params(params)

          CreatePollingStationResults.call(@form, closure) do
            on(:ok) do
              flash[:notice] = t(".success")
            end

            on(:invalid) do
              flash[:alert] = t(".error")
            end
          end

          redirect_to polling_officer_election_closure_path(polling_officer, election)
        end

        private

        def polling_officer
          @polling_officer ||= polling_officers.find_by(id: params[:polling_officer_id])
        end

        def election
          @election ||= Decidim::Elections::Election.includes(questions: :answers).find_by(id: params[:election_id])
        end

        def polling_station
          @polling_station ||= polling_officer.polling_station
        end

        def closure
          @closure ||= polling_station.closures.find_by(election: election)
        end

        def polling_station_election_votes_count
          # the votes count should/will be scoped to the polling station
          @polling_station_election_votes_count ||= election.votes&.count
        end
      end
    end
  end
end
