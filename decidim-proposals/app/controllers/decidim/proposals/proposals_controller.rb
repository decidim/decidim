# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      include FormFactory
      include FilterResource

      helper_method :order, :random_seed, :geocoded_proposals

      before_action :authenticate_user!, only: [:new, :create]

      def index
        @proposals = search
                     .results
                     .not_hidden
                     .includes(:author)
                     .includes(:category)
                     .includes(:scope)

        @voted_proposals = if current_user
                             ProposalVote.where(
                               author: current_user,
                               proposal: @proposals
                             ).pluck(:decidim_proposal_id)
                           else
                             []
                           end

        @proposals = @proposals.page(params[:page]).per(12)
        @proposals = reorder(@proposals)
      end

      def show
        @proposal = Proposal.not_hidden.where(feature: current_feature).find(params[:id])
        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")
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

      # Gets how the proposals should be ordered based on the choice made by the user.
      def order
        @order ||= available_orders.detect { |order| order == params[:order] } || "random"
      end

      # Available orders based on enabled settings
      def available_orders
        if current_settings.votes_enabled? && current_settings.votes_hidden?
          %w(random recent)
        else
          %w(random recent most_voted)
        end
      end

      # Returns: A random float number between -1 and 1 to be used as a random seed at the database.
      def random_seed
        @random_seed ||= (params[:random_seed] ? params[:random_seed].to_f : (rand * 2 - 1))
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
        end
      end

      def geocoded_proposals
        @geocoded_proposals ||= search.results.not_hidden.select(&:geocoded?)
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
          state: "all",
          scope_id: nil,
          related_to: ""
        }
      end
    end
  end
end
