# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal vote resource so users can vote proposals.
    class ProposalVotesController < Decidim::Proposals::ApplicationController
      include ProposalVotesHelper

      before_action :authenticate_user!
      before_action :check_current_settings!
      before_action :check_vote_limit_reached!, only: [:create]

      def create
        proposal.votes.create!(author: current_user)
        @from_proposals_list = params[:from_proposals_list] == "true"
        render :update_buttons_and_counters
      end

      def destroy
        proposal.votes.where(author: current_user).first.destroy
        @from_proposals_list = params[:from_proposals_list] == "true"
        render :update_buttons_and_counters
      end

      private

      # The vote buttons should not be visible if the setting is not enabled.
      # This ensure the votes cannot be created using a POST request directly.
      def check_current_settings!
        raise "This setting is not enabled for this step" unless current_settings.votes_enabled?
      end

      # The vote buttons should not be enabled if the vote limit is reached.
      # This ensure the votes cannot be created using a POST request directly.
      def check_vote_limit_reached!
        raise "Vote limit reached" if vote_limit_enabled? && remaining_votes_count_for(current_user) == 0
      end

      def proposal
        @proposal ||= Proposal.where(feature: current_feature).find(params[:proposal_id])
      end
    end
  end
end
