# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      include FormFactory
      include FilterResource

      before_action :authenticate_user!, only: [:new, :create]

      def show
        @proposal = Proposal.where(feature: current_feature).find(params[:id])
      end

      def index
        @proposals = search.results
        @random_seed = search.random_seed
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

      private

      def search_klass
        ProposalSearch
      end

      def default_search_params
        {
          page: params[:page],
          per_page: 12,
        }
      end

      def default_filter_params
        {
          search_text: "",
          origin: "all",
          category_id: "",
          random_seed: params[:random_seed] || @random_seed
        }
      end
    end
  end
end
