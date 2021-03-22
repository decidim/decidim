# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class VotesController < Decidim::Elections::ApplicationController
      layout "decidim/election_votes"
      include FormFactory

      helper VotesHelper
      helper_method :elections, :election, :questions, :questions_count, :preview_mode?, :vote, :bulletin_board_server, :authority_public_key, :scheme_name, :election_unique_id

      delegate :count, to: :questions, prefix: true

      def new
        return redirect_to(return_path, alert: t("votes.messages.not_allowed", scope: "decidim.elections")) unless vote_mode? || preview_mode?
        return redirect_to(election_vote_path(election, id: pending_vote.encrypted_vote_hash)) if pending_vote

        @form = form(Voter::VoteForm).instance(election: election)
      end

      def create
        if vote_mode?
          @form = form(Voter::VoteForm).from_params(params, election: election)
          Voter::CastVote.call(@form)
        end

        redirect_to election_vote_path(election, id: params[:vote][:encrypted_data_hash])
      end

      def show; end

      def update
        Voter::UpdateVoteStatus.call(vote) do
          on(:ok) do
            redirect_to election_vote_path(election, id: vote.encrypted_vote_hash)
          end
          on(:invalid) do
            flash[:alert] = I18n.t("votes.update.error", scope: "decidim.elections")
            redirect_to election
          end
        end
      end

      def verify
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

      def vote_mode?
        return @vote_mode if defined?(@vote_mode)

        @vote_mode = allowed_to? :vote, :election, election: election
      end

      def preview_mode?
        return @preview_mode if defined?(@preview_mode)

        @preview_mode = !vote_mode? && allowed_to?(:preview, :election, election: election)
      end

      def return_path
        @return_path ||= if allowed_to? :view, :election, election: election
                           election_path(election)
                         else
                           elections_path
                         end
      end

      def pending_vote
        @pending_vote ||= Decidim::Elections::Votes::PendingVotes.for.find_by(user: current_user, election: election)
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
        @questions ||= election.questions.includes(:answers).order(weight: :asc, id: :asc)
      end
    end
  end
end
