# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal adhesion resource so users can adhere to proposals.
    class ProposalAdhesionsController < Decidim::Proposals::ApplicationController
      include ProposalAdhesionsHelper
      include Rectify::ControllerHelpers
      helper_method :proposal

      before_action :authenticate_user!

      def create
        authorize! :adhere, proposal
        @from_proposals_list = params[:from_proposals_list] == "true"
        user_group_id= params[:user_group_id]

        AdhereProposal.call(proposal, current_user, user_group_id) do
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
        user_group_id= params[:user_group_id]
        user_group= current_user.user_groups.verified.find(user_group_id) if user_group_id

        UnadhereProposal.call(proposal, current_user, user_group) do
          on(:ok) do
            proposal.reload
            render :update_buttons_and_counters
          end
        end
      end

      def identities
        authorize! :adhere, proposal

        ShowAdhesionIdentities.call(proposal, current_user) do
          on(:ok) do |groups_split|
            expose(
              to_adhere_groups: groups_split[:adhere],
              to_unadhere_groups: groups_split[:unadhere]
            )
            render :identities, layout: false
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
