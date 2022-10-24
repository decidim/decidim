# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows a monitoring committee member to list and validate the polling stations closures.
      class MonitoringCommitteeElectionResultsController < Admin::ApplicationController
        include VotingAdmin

        helper_method :current_voting, :elections, :election, :publish_results_form, :bulletin_board_server

        def index
          enforce_permission_to :read, :monitoring_committee_election_results, voting: current_voting

          redirect_to voting_monitoring_committee_election_result_path(current_voting, elections.first) if elections.one?
        end

        def show
          enforce_permission_to :read, :monitoring_committee_election_result, voting: current_voting, election:
        end

        def update
          enforce_permission_to :validate, :monitoring_committee_election_result, voting: current_voting, election: election

          if publish_results_form.pending_action
            Decidim::Elections::Admin::UpdateActionStatus.call(publish_results_form.pending_action)

            if publish_results_form.pending_action.accepted?
              flash[:notice] = I18n.t("monitoring_committee_election_results.update.success", scope: "decidim.votings.admin")
            else
              flash[:alert] = I18n.t("monitoring_committee_election_results.update.rejected", scope: "decidim.votings.admin")
            end

            return redirect_to voting_monitoring_committee_election_result_path(current_voting, election)
          end

          Decidim::Elections::Admin::PublishResults.call(publish_results_form) do
            on(:invalid) do
              flash.now[:alert] = I18n.t("monitoring_committee_election_results.update.invalid", scope: "decidim.votings.admin")
            end
            on(:ok) do
              publish_results_form.refresh
            end
          end

          render :show
        end

        private

        def bulletin_board_server
          Decidim::Elections.bulletin_board.bulletin_board_server
        end

        def elections
          @elections = current_voting.published_elections
        end

        def election
          @election = elections.find_by(id: params[:id])
        end

        def publish_results_form
          @publish_results_form ||= form(Decidim::Votings::Admin::PublishResultsForm).from_params(params, election:)
        end
      end
    end
  end
end
