# frozen_string_literal: true
require_dependency "application_controller"

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      def new
        @form = ProposalForm.from_params({}, author: current_user)
      end

      def index
        @proposals = collection
      end

      def create
        @form = ProposalForm.from_params(params, author: current_user)

        CreateProposal.call(@form, current_feature) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")
            redirect_to proposal_path(proposal)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            render :new
          end
        end
      end

      def show
        @proposal = collection.find(params[:id])
      end

      private

      def collection
        @collection ||= Proposal.where(feature: current_feature)
      end
    end
  end
end
