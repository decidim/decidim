# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class VotesController < Decidim::Elections::ApplicationController
      layout "decidim/election_votes"
      include FormFactory

      helper VotesHelper
      helper_method :elections, :election, :questions, :questions_count, :booth_mode, :vote

      delegate :count, to: :questions, prefix: true

      def new
        return redirect_to(return_path, alert: t("votes.messages.not_allowed", scope: "decidim.elections")) if booth_mode.nil?
        return redirect_to(pending_vote_path) if pending_vote?

        @form = form(Voter::EncryptedVoteForm).instance(election: election)
      end

      def update
        Voter::UpdateVoteStatus.call(vote) do
          on(:ok) do
            flash[:notice] = I18n.t("votes.update.success", scope: "decidim.elections")
          end
          on(:invalid) do
            flash[:alert] = I18n.t("votes.update.error", scope: "decidim.elections")
          end
        end
      end

      def cast
        @form = form(Voter::EncryptedVoteForm).from_params(params, election: election)
        return render :cast_success, locals: { message_id: "PreviewMessageId", vote_id: nil } if preview?

        Voter::CastVote.call(@form) do
          on(:ok) do |vote|
            render :cast_success, locals: { message_id: vote.message_id, vote_id: vote.id }
          end
          on(:invalid) do
            render :cast_failed
          end
        end
      end

      def verify
        @form = form(Ballot::VerifyVoteForm).instance(election: election)
      end

      private

      def vote
        @vote ||= Decidim::Elections::Vote.find_by(id: params[:vote_id])
      end

      def pending_vote?
        Decidim::Elections::Votes::PendingVotes.for.exists?(user: current_user, election: election)
      end

      def booth_mode
        @booth_mode ||= if allowed_to? :vote, :election, election: election
                          :vote
                        elsif allowed_to? :preview, :election, election: election
                          :preview
                        end
      end

      def return_path
        @return_path ||= if allowed_to? :view, :election, election: election
                           election_path(election)
                         else
                           elections_path
                         end
      end

      def pending_vote_path
        @pending_vote_path ||= if allowed_to? :view, :election, election: election
                                 verify_election_vote_path(election)
                               else
                                 elections_path
                               end
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

      def preview?
        booth_mode == :preview
      end
    end
  end
end
