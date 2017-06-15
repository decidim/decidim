# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal vote resource so users can vote proposals.
    class ProposalVotesController < Decidim::Proposals::ApplicationController
      include ProposalVotesHelper

      helper_method :proposal

      before_action :authenticate_user!

      def create
        authorize! :vote, proposal
        @from_proposals_list = params[:from_proposals_list] == "true"

        VoteProposal.call(proposal, current_user) do
          on(:ok) do
            proposal.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render json: { error: I18n.t("proposal_votes.create.error", scope: "decidim.proposals") }, status: 422
          end
        end
      end

      def destroy
        authorize! :unvote, proposal
        @from_proposals_list = params[:from_proposals_list] == "true"

        UnvoteProposal.call(proposal, current_user) do
          on(:ok) do
            proposal.reload
            render :update_buttons_and_counters
          end
        end
      end

      private

      def proposal
        @proposal ||= Proposal.where(feature: current_feature).find(params[:proposal_id])
      end
    end
  end
end
