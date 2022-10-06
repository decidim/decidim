# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # Space to manage the elections for a Polling Station Officer
      class InPersonVotesController < Decidim::Votings::PollingOfficerZone::ApplicationController
        include FormFactory
        include Decidim::Elections::HasVoteFlow

        helper_method :polling_officer, :election, :in_person_form, :has_voter?,
                      :vote_check, :cant_vote_reason, :questions, :in_person_vote_form, :voted_online?,
                      :in_person_vote, :bulletin_board_server, :exit_path

        helper Decidim::Admin::IconLinkHelper

        def new
          enforce_permission_to :manage, :in_person_vote, polling_officer: polling_officer

          has_pending_in_person_vote?
        end

        def create
          enforce_permission_to :manage, :in_person_vote, polling_officer: polling_officer

          return if has_pending_in_person_vote?

          if verified_voter?
            store_in_person_vote
          else
            identify_voter
          end
        end

        def show
          enforce_permission_to :manage, :in_person_vote, polling_officer:
        end

        def update
          enforce_permission_to :manage, :in_person_vote, polling_officer: polling_officer

          Decidim::Votings::Voter::UpdateInPersonVoteStatus.call(in_person_vote) do
            on(:ok) do
              message_type = in_person_vote.accepted? ? :notice : :alert
              flash[message_type] = I18n.t("in_person_votes.update.success.#{in_person_vote.status}", scope: "decidim.votings.polling_officer_zone")
            end
            on(:invalid) do
              flash[:alert] = I18n.t("in_person_votes.update.error", scope: "decidim.votings.polling_officer_zone")
            end
          end
          redirect_to exit_path
        end

        private

        attr_reader :cant_vote_reason

        delegate :bulletin_board_server, to: :bulletin_board_client
        delegate :has_voter?, to: :vote_flow
        delegate :polling_station, to: :polling_officer

        def bulletin_board_client
          @bulletin_board_client ||= Decidim::Elections.bulletin_board
        end

        def has_pending_in_person_vote?
          if pending_in_person_vote.present?
            redirect_to(polling_officer_election_in_person_vote_path(polling_officer, election, id: pending_in_person_vote.id))
            true
          end
        end

        def identify_voter
          vote_flow.voter_in_person(params) if in_person_form.valid?

          render :new
        end

        def vote_check
          @vote_check ||= vote_flow.vote_check
        end

        def verified_voter?
          params[:in_person_vote] &&
            vote_flow.voter_from_token(params.require(:in_person_vote).permit(:voter_token, :voter_id))
        end

        def store_in_person_vote
          return redirect_to exit_path, alert: vote_check.error_message unless vote_check.allowed?

          Decidim::Votings::Voter::InPersonVote.call(in_person_vote_form) do
            on(:ok) do |created_in_person_vote|
              redirect_to polling_officer_election_in_person_vote_path(polling_officer, election, created_in_person_vote)
            end
            on(:invalid) do
              flash[:alert] = I18n.t("in_person_votes.create.error", scope: "decidim.votings.polling_officer_zone")
              redirect_to exit_path
            end
          end
        end

        def in_person_form
          @in_person_form ||= form(Decidim::Votings::Census::InPersonForm).from_params(params)
        end

        def in_person_vote_form
          @in_person_vote_form ||= form(Decidim::Votings::Voter::InPersonVoteForm).from_params(
            {
              voter_token:,
              voter_id:,
              voted: params.dig(:in_person_vote, :voted)
            },
            election:,
            polling_station:,
            polling_officer:
          )
        end

        def voted_online?
          Decidim::Elections::Votes::LastVoteForVoter.for(election, vote_flow.voter_id) if vote_flow.has_voter?
        end

        def election
          @election ||= Decidim::Elections::Election.find(params[:election_id])
        end

        def polling_officer
          @polling_officer ||= Decidim::Votings::PollingOfficer.find(params[:polling_officer_id])
        end

        def questions
          @questions ||= ballot_questions.includes(:answers).order(weight: :asc, id: :asc)
        end

        def in_person_vote
          @in_person_vote ||= Decidim::Votings::InPersonVote.find_by(id: params[:id]) if params[:id]
        end

        def pending_in_person_vote
          @pending_in_person_vote ||= Decidim::Votings::Votes::PendingInPersonVotes.for.find_by(polling_officer:, election:)
        end

        def exit_path
          @exit_path ||= new_polling_officer_election_in_person_vote_path(polling_officer, election)
        end
      end
    end
  end
end
