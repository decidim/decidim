# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      include FormFactory
      include FilterResource

      helper_method :order, :random_seed

      before_action :authenticate_user!, only: [:new, :create]

      def show
        @proposal = Proposal.where(feature: current_feature).find(params[:id])
      end

      def index
        @proposals = search
                     .results
                     .includes(:author)
                     .includes(votes: [:author])

        @proposals = reorder(@proposals)

        @proposals = @proposals.page(params[:page]).per(12)
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

      def order
        @order = params[:order] || "random"
      end

      # Returns: A random flaot number between -1 and 1 to be used as a random seed at the database.
      def random_seed
        @random_seed = params[:random_seed].to_f || (rand * 2 - 1)
      end

      def reorder(proposals)
        case order
        when "random"
          Proposal.transaction do
            Proposal.connection.execute("SELECT setseed(#{Proposal.connection.quote(random_seed)})")
            proposals.order("RANDOM()").load
          end
        when "most_voted"
          proposals.order(proposal_votes_count: :desc)
        when "recent"
          proposals.order(created_at: :desc)
        else
          proposals
        end
      end

      def search_klass
        ProposalSearch
      end

      def default_filter_params
        {
          search_text: "",
          origin: "all",
          activity: "",
          category_id: "",
          state: "all"
        }
      end
    end
  end
end
