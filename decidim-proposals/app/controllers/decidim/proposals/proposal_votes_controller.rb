# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal vote resource so users can vote proposals.
    class ProposalVotesController < Decidim::Proposals::ApplicationController
      before_action :authenticate_user!
      before_action :check_current_settings!

      def create
        proposal.votes.create!(author: current_user)
        @from_proposals_list = params[:from_proposals_list] == "true"
        render :update_counters
      end

      def destroy
        proposal.votes.where(author: current_user).first.destroy
        @from_proposals_list = params[:from_proposals_list] == "true"
        render :update_counters
      end

      private

      # The vote buttons should not be visible if the setting is not enabled.
      # This ensure the votes cannot be created using a POST request directly.
      def check_current_settings!
        raise "This setting is not enabled for this step" unless current_settings.votes_enabled?
      end

      def proposal
        @proposal ||= Proposal.where(feature: current_feature).find(params[:proposal_id])
      end
    end
  end
end
