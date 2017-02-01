# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      include FormFactory
      include FilterResource

      before_action :authenticate_user!, only: [:new, :create]
      authorize_action! :vote, only: [:index]

      def show
        @proposal = Proposal.where(feature: current_feature).find(params[:id])
      end

      def index
        @proposals = search
                     .results
                     .includes(:author)
                     .includes(votes: [:author])
                     .page(params[:page])
                     .per(12)

        @random_seed = search.random_seed
      end

      def new
        authorize! :create, Proposal

        @form = form(ProposalForm).from_params({})
      end

      def create
        authorize! :create, Proposal

        @form = form(ProposalForm).from_params(params)

        CreateProposal.call(@form, current_user) do
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

      def default_filter_params
        {
          search_text: "",
          origin: "all",
          activity: "",
          category_id: "",
          state: "all",
          random_seed: params[:random_seed]
        }
      end
    end
  end
end
