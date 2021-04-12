# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Space to manage the elections results for a Polling Station Officer
      class ResultsController < Decidim::Votings::PollingOfficerZone::ApplicationController
        helper_method :election, :polling_officer, :polling_station

        def new
          enforce_permission_to :manage, :polling_station_results, polling_officer: polling_officer
          @form = form(ElectionResultForm).from_model(form_models)
        end

        def create
          enforce_permission_to :manage, :polling_station_results, polling_officer: polling_officer
          @form = form(ElectionResultForm).from_params(params)

          CreatePollingStationResults.call(@form, polling_officer) do
            on(:ok) do
              flash[:notice] = t(".success")
            end

            on(:invalid) do
              flash[:alert] = t(".error")
            end
          end

          redirect_to polling_officers_path
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

        def form_models
          @form_models ||= begin
            OpenStruct.new(
              election: election,
              polling_station: polling_station
            )
          end
        end
      end
    end
  end
end
