# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal vote resource so users can vote proposals.
    class ProposalVotesController < Decidim::Proposals::ApplicationController
      before_action :authenticate_user!

      def create
        @proposal = Proposal.where(feature: current_feature).find(params[:proposal_id])
        @proposal.votes.create!(author: current_user)
        @from_proposals_list = params[:from_proposals_list] == "true"
      end
    end
  end
end
