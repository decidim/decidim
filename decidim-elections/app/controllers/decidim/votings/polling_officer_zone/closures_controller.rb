# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Space to manage the election closure of a Polling Station
      class ClosuresController < Decidim::Votings::PollingOfficerZone::ApplicationController
        helper_method :election, :polling_officer, :polling_station, :closure

        def show
          enforce_permission_to :manage, :polling_station_results, polling_officer: polling_officer

          @form = if closure.certificate_phase?
                    form(ClosureCertifyForm).instance.with_context(closure:)
                  elsif closure.signature_phase?
                    form(ClosureSignForm).instance
                  end
        end

        def new
          enforce_permission_to :create, :polling_station_results, polling_officer: polling_officer

          @form = EnvelopesResultForm.new(
            polling_station_id: polling_station.id,
            election_id: election.id,
            election_votes_count: polling_station_election_votes_count
          )
        end

        def create
          enforce_permission_to :create, :polling_station_results, polling_officer: polling_officer
          @form = form(EnvelopesResultForm).from_params(params).with_context(polling_officer:)

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
          enforce_permission_to :edit, :polling_station_results, polling_officer: polling_officer, closure: closure

          @form = form(ClosureResultForm).from_model(closure)
        end

        def update
          enforce_permission_to :edit, :polling_station_results, polling_officer: polling_officer, closure: closure
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

        def certify
          enforce_permission_to :edit, :polling_station_results, polling_officer: polling_officer, closure: closure

          @form = form(ClosureCertifyForm).from_params(params).with_context(closure:)

          CertifyPollingStationClosure.call(@form, closure) do
            on(:ok) do
              flash[:notice] = t(".success")
            end

            on(:invalid) do
              flash[:alert] = t(".error")
            end
          end

          redirect_to polling_officer_election_closure_path(polling_officer, election)
        end

        def sign
          enforce_permission_to :edit, :polling_station_results, polling_officer: polling_officer, closure: closure

          @form = form(ClosureSignForm).from_params(params)

          SignPollingStationClosure.call(@form, closure) do
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
          @closure ||= polling_station.closures.find_by(election:)
        end

        def polling_station_election_votes_count
          @polling_station_election_votes_count ||= polling_station.in_person_votes.where(election:).count
        end
      end
    end
  end
end
