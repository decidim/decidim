# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      helper_method :scopes, :categories

      def new
        @form = ProposalForm.from_params({}, author: current_user, feature: current_feature)
      end

      def index
        @proposals = collection
      end

      def create
        @form = ProposalForm.from_params(params, author: current_user, feature: current_feature)

        CreateProposal.call(@form) do
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

      def scopes
        @scopes ||= current_organization.scopes
      end

      def categories
        current_feature.categories
      end

      def collection
        @collection ||= Proposal.where(feature: current_feature)
      end
    end
  end
end
