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

        proposal.votes.create!(author: current_user)
        @from_proposals_list = params[:from_proposals_list] == "true"
        render :update_buttons_and_counters
      end

      def destroy
        authorize! :unvote, proposal

        proposal.votes.where(author: current_user).delete_all
        @from_proposals_list = params[:from_proposals_list] == "true"
        render :update_buttons_and_counters
      end

      private

      def proposal
        @proposal ||= Proposal.where(feature: current_feature).find(params[:proposal_id])
      end
    end
  end
end
