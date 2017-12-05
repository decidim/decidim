# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal adhesion resource so users can adhere to proposals.
    class ProposalAdhesionsController < Decidim::Proposals::ApplicationController
      include ProposalAdhesionsHelper

      helper_method :proposal

      before_action :authenticate_user!

      def create
        authorize! :adhere, proposal
        @from_proposals_list = params[:from_proposals_list] == "true"

        AdhereProposal.call(proposal, current_user) do
          on(:ok) do
            proposal.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render json: { error: I18n.t("proposal_adhesions.create.error", scope: "decidim.proposals") }, status: 422
          end
        end
      end

      def destroy
        authorize! :unadhere, proposal
        @from_proposals_list = params[:from_proposals_list] == "true"

        UnadhereProposal.call(proposal, current_user) do
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
