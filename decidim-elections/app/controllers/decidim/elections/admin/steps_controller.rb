# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows to manage the steps of an election.
      class StepsController < Admin::ApplicationController
        helper Decidim::ApplicationHelper
        helper StepsHelper
        helper_method :elections, :election, :current_step, :vote_stats, :bulletin_board_server, :authority_public_key, :election_unique_id, :quorum, :missing_trustees_allowed

        def index
          enforce_permission_to :read, :steps, election: election

          if current_step_form_class
            @form = form(current_step_form_class).instance(election:)
            @form.valid?
          end
        end

        def update
          enforce_permission_to :update, :steps, election: election
          redirect_to election_steps_path(election) && return unless params[:id] == current_step

          @form = form(current_step_form_class).from_params(params, election:)
          Decidim::Elections::Admin::UpdateActionStatus.call(@form.pending_action) if @form.pending_action

          # check pending action status mode
          return render json: { status: @form.pending_action&.status } if params[:check_pending_action]

          return redirect_to election_steps_path(election) if @form.pending_action

          current_step_command_class.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("steps.#{current_step}.success", scope: "decidim.elections.admin")
              return redirect_to election_steps_path(election)
            end
            on(:invalid) do |message|
              flash.now[:alert] = message || I18n.t("steps.#{current_step}.invalid", scope: "decidim.elections.admin")
            end
          end
          render :index
        end

        def stats
          render "decidim/elections/admin/steps/_vote_stats", layout: false
        end

        private

        delegate :bulletin_board_server, :authority_slug, :quorum, to: :bulletin_board_client

        def bulletin_board_client
          Decidim::Elections.bulletin_board
        end

        def missing_trustees_allowed
          @missing_trustees_allowed ||= Decidim::Elections.bulletin_board.number_of_trustees - Decidim::Elections.bulletin_board.quorum
        end

        def election_unique_id
          @election_unique_id ||= Decidim::BulletinBoard::MessageIdentifier.unique_election_id(authority_slug, election.id)
        end

        def authority_public_key
          @authority_public_key ||= bulletin_board_client.authority_public_key.to_json
        end

        def current_step_form_class
          @current_step_form_class ||= {
            "create_election" => SetupForm,
            "created" => ActionForm,
            "key_ceremony_ended" => VotePeriodForm,
            "vote" => VotePeriodForm,
            "vote_ended" => ActionForm,
            "tally_started" => ReportMissingTrusteeForm,
            "tally_ended" => ActionForm
          }[current_step]
        end

        def current_step_command_class
          @current_step_command_class ||= {
            "create_election" => SetupElection,
            "created" => StartKeyCeremony,
            "key_ceremony_ended" => StartVote,
            "vote" => EndVote,
            "vote_ended" => StartTally,
            "tally_started" => ReportMissingTrustee,
            "tally_ended" => PublishResults
          }[current_step]
        end

        def current_step
          @current_step ||= election.bb_status || "create_election"
        end

        def elections
          @elections ||= Election.where(component: current_component)
        end

        def election
          @election ||= elections.find_by(id: params[:election_id])
        end

        def vote_stats
          @vote_stats ||= {
            votes: vote_counts.first,
            voters: vote_counts.last
          }
        end

        def vote_counts
          @vote_counts ||= Decidim::Elections::Admin::VotesForStatistics.for(election)
        end
      end
    end
  end
end
