# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class VotesController < Decidim::Elections::ApplicationController
      layout "decidim/election_votes"
      include FormFactory
      include HasVoteFlow

      helper VotesHelper
      helper_method :bulletin_board_server, :authority_public_key, :scheme_name, :election_unique_id,
                    :exit_path, :elections, :election, :questions, :questions_count, :vote

      delegate :count, to: :questions, prefix: true

      def new
        return if access_denied?

        @form = form(Voter::VoteForm).from_params({ voter_token: voter_token, voter_id: voter_id },
                                                  election: election, user: vote_flow.user)
      end

      def create
        return unless valid_voter_token?
        return if access_denied?

        unless preview_mode?
          @form = form(Voter::VoteForm).from_params(params, election: election, user: vote_flow.user, email: vote_flow.email)
          Voter::CastVote.call(@form)
        end

        redirect_to election_vote_path(election, id: params[:vote][:encrypted_data_hash], token: vote_flow.voter_id_token)
      end

      def show
        enforce_permission_to :view, :election, election: election
      end

      def update
        enforce_permission_to :view, :election, election: election

        Voter::UpdateVoteStatus.call(vote) do
          on(:ok) do
            redirect_to election_vote_path(election, id: vote.encrypted_vote_hash, token: vote_flow.voter_id_token(vote.voter_id))
          end
          on(:invalid) do
            flash[:alert] = I18n.t("votes.update.error", scope: "decidim.elections")
            redirect_to exit_path
          end
        end
      end

      def verify
        enforce_permission_to :view, :election, election: election

        @form = form(Voter::VerifyVoteForm).instance(election: election)
      end

      private

      delegate :bulletin_board_server, :scheme_name, to: :bulletin_board_client

      def election_unique_id
        @election_unique_id ||= Decidim::BulletinBoard::MessageIdentifier.unique_election_id(bulletin_board_client.authority_slug, election.id)
      end

      def vote
        @vote ||= Decidim::Elections::Vote.find_by(encrypted_vote_hash: params[:id]) if params[:id]
      end

      def exit_path
        @exit_path ||= if allowed_to? :view, :election, election: election
                         election_path(election)
                       else
                         elections_path
                       end
      end

      def pending_vote
        @pending_vote ||= Decidim::Elections::Votes::PendingVotes.for.find_by(voter_id: voter_id, election: election)
      end

      def bulletin_board_client
        @bulletin_board_client ||= Decidim::Elections.bulletin_board
      end

      def authority_public_key
        @authority_public_key ||= bulletin_board_client.authority_public_key.to_json
      end

      def elections
        @elections ||= Election.where(component: current_component)
      end

      def election
        @election ||= elections.find(params[:election_id])
      end

      def questions
        @questions ||= ballot_questions.includes(:answers).order(weight: :asc, id: :asc)
      end

      def access_denied?
        if preview_mode?
          return redirect_to(exit_path, alert: t("votes.messages.not_allowed", scope: "decidim.elections")) unless can_preview?

          return
        end

        return redirect_to(vote_flow.login_path(new_election_vote_path) || exit_path, alert: vote_flow.no_access_message, status: :temporary_redirect) unless vote_flow.can_vote?
        return redirect_to(election_vote_path(election, id: pending_vote.encrypted_vote_hash, token: vote_flow.voter_id_token)) if pending_vote.present?

        enforce_permission_to :vote, :election, election: election
      end

      def valid_voter_token?
        return unless vote_flow.receive_data(params.require(:vote).permit(:voter_token, :voter_id))

        unless preview_mode? || vote_flow.valid_received_data?
          redirect_to(exit_path, alert: t("votes.messages.invalid_token", scope: "decidim.elections"))
          return
        end

        true
      end
    end
  end
end
