# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      helper_method :filter, :search_params

      include FormFactory
      before_action :authenticate_user!, only: [:new, :create]

      def show
        @proposal = Proposal.where(feature: current_feature).find(params[:id])
      end

      def index
        @search = ProposalSearch.new(search_params.merge(context_params))
        @proposals = @search.results
        @random_seed = @search.random_seed        
        # @search = ProposalSearch.new(current_feature, params[:page], params[:random_seed])
        # @proposals = @search.proposals
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

      def filter
        @filter ||= filter_klass.new(params.dig(:filter, :category_id))
      end

      def search_params
        default_search_params
          .merge(params.to_unsafe_h.except(:filter))
          .merge(params.to_unsafe_h[:filter] || {})
      end

      # Internal: Defines a class that will wrap in an object the URL params used by the filter.
      # this way we can use Rails' form helpers and have automatically checked checkboxes and
      # radio buttons in the view, for example.
      def filter_klass
        Struct.new(:category_id)
      end

      def default_search_params
        {
          page: params[:page]
        }.with_indifferent_access
      end

      def context_params
        {
          feature: current_feature
        }
      end
    end
  end
end
