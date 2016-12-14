# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      helper_method :scopes, :categories, :proposals

      def new
        @form = ProposalForm.from_params({}, author: current_user, feature: current_feature)
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
        @proposal = Proposal.where(feature: current_feature).find(params[:id])
      end

      private

      def scopes
        @scopes ||= current_organization.scopes
      end

      def categories
        current_feature.categories
      end

      def proposals
        @proposals ||= Proposal.transaction do
          Proposal.connection.execute("SELECT setseed(#{Proposal.connection.quote(random_seed)})")
          Proposal.where(feature: current_feature).reorder("RANDOM()").page(page).per(per_page).load
        end
      end

      def random_seed
        return (rand * 2 - 1) if !params[:random_seed] || params[:random_seed].to_f == 0.0
        params[:random_seed]
      end

      def page
        params[:page] || 1
      end

      def per_page
        12
      end
    end
  end
end
