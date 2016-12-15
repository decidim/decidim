# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      include FormFactory
      before_action :authenticate_user!, only: [:new, :create]

      def show
        @proposal = Proposal.where(feature: current_feature).find(params[:id])
      end

      def index
        @proposals = ProposalSearch.new(current_feature, params[:page], params[:random_seed]).proposals
      end

      def new
        @form = form(ProposalForm).from_params({}, author: current_user, feature: current_feature)
      end

      def create
        @form = form(ProposalForm).from_params(params, author: current_user, feature: current_feature)

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
    end
  end
end
