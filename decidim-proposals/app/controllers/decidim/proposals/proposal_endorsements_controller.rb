# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal endorsement resource so that users can endorse proposals.
    class ProposalEndorsementsController < Decidim::Proposals::ApplicationController
      helper_method :proposal

      before_action :authenticate_user!

      def create
        enforce_permission_to :endorse, :proposal, proposal: proposal
        @from_proposals_list = params[:from_proposals_list] == "true"
        user_group_id = params[:user_group_id]

        EndorseProposal.call(proposal, current_user, user_group_id) do
          on(:ok) do
            proposal.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render json: { error: I18n.t("proposal_endorsements.create.error", scope: "decidim.proposals") }, status: :unprocessable_entity
          end
        end
      end

      def destroy
        enforce_permission_to :unendorse, :proposal, proposal: proposal
        @from_proposals_list = params[:from_proposals_list] == "true"
        user_group_id = params[:user_group_id]
        user_group = user_groups.find(user_group_id) if user_group_id

        UnendorseProposal.call(proposal, current_user, user_group) do
          on(:ok) do
            proposal.reload
            render :update_buttons_and_counters
          end
        end
      end

      def identities
        enforce_permission_to :endorse, :proposal, proposal: proposal

        @user_verified_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
        render :identities, layout: false
      end

      private

      def user_groups
        Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
      end

      def proposal
        @proposal ||= Proposal.where(component: current_component).find(params[:proposal_id])
      end
    end
  end
end
