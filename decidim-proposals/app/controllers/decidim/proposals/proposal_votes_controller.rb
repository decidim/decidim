# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal vote resource so users can vote proposals.
    class ProposalVotesController < Decidim::Proposals::ApplicationController
      before_action :authenticate_user!

      def create
        @proposal = Proposal.find(params[:proposal_id])
        @proposal.votes.create!(author: current_user)
      end
    end
  end
end
