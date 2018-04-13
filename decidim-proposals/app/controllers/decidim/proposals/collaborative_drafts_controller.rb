# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes Collaborative Drafts resource so users can view and create them.
    class CollaborativeDraftsController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      helper ProposalWizardHelper
      include FormFactory
      include FilterResource
      include CollaborativeOrderable
      include Paginable

      helper_method :geocoded_proposals
      before_action :authenticate_user!, only: [:new, :create]

      def index
        @collaborative_drafts = search
                                .results
                                .includes(:author)
                                .includes(:category)
                                .includes(:scope)

        @collaborative_drafts = paginate(@collaborative_drafts)
        @collaborative_drafts = reorder(@collaborative_drafts)
      end

      def show
        @collaborative_draft = CollaborativeDraft.where(component: current_component).find(params[:id])
        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")
      end

      # def new
      #   authorize! :create, Proposal
      #   @step = :step_1
      #   if proposal_draft.present?
      #     redirect_to edit_draft_proposal_path proposal_draft.id
      #   else
      #     @form = form(ProposalForm).from_params(
      #       attachment: form(AttachmentForm).from_params({})
      #     )
      #   end
      # end

      # def create
      #   authorize! :create, Proposal
      #   @step = :step_1
      #   @form = form(ProposalForm).from_params(params)

      #   CreateProposal.call(@form, current_user) do
      #     on(:ok) do |proposal|
      #       flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")
      #       compare_path = Decidim::ResourceLocatorPresenter.new(proposal).path + "/compare"
      #       redirect_to compare_path
      #     end

      #     on(:invalid) do
      #       flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
      #       render :new
      #     end
      #   end
      # end

      # def compare
      #   @step = :step_2
      #   @similar_proposals ||= Decidim::Proposals::SimilarProposals
      #                          .for(current_component, @proposal)
      #                          .all

      #   if @similar_proposals.blank?
      #     flash[:notice] = I18n.t("proposals.proposals.compare.no_similars_found", scope: "decidim")
      #     redirect_to preview_proposal_path(@proposal)
      #   end
      # end

      # def preview
      #   @step = :step_3
      # end

      # def publish
      #   @step = :step_3
      #   PublishProposal.call(@proposal, current_user) do
      #     on(:ok) do |proposal|
      #       flash[:notice] = I18n.t("proposals.publish.success", scope: "decidim")
      #       redirect_to proposal_path(proposal)
      #     end

      #     on(:invalid) do
      #       flash.now[:alert] = I18n.t("proposals.publish.error", scope: "decidim")
      #       render :edit_draft
      #     end
      #   end
      # end

      # def edit_draft
      #   @step = :step_1
      #   authorize! :edit, Proposal

      #   @form = form(ProposalForm).from_model(@proposal)
      # end

      # def update_draft
      #   @step = :step_1
      #   authorize! :edit, @proposal

      #   @form = form(ProposalForm).from_params(params)
      #   UpdateProposal.call(@form, current_user, @proposal) do
      #     on(:ok) do |proposal|
      #       flash[:notice] = I18n.t("proposals.update_draft.success", scope: "decidim")
      #       redirect_to preview_proposal_path(proposal)
      #     end

      #     on(:invalid) do
      #       flash.now[:alert] = I18n.t("proposals.update_draft.error", scope: "decidim")
      #       render :edit_draft
      #     end
      #   end
      # end

      # def edit
      #   @proposal = Proposal.published.not_hidden.where(component: current_component).find(params[:id])
      #   authorize! :edit, @proposal

      #   @form = form(ProposalForm).from_model(@proposal)
      # end

      # def update
      #   @proposal = Proposal.not_hidden.where(component: current_component).find(params[:id])
      #   authorize! :edit, @proposal

      #   @form = form(ProposalForm).from_params(params)
      #   UpdateProposal.call(@form, current_user, @proposal) do
      #     on(:ok) do |proposal|
      #       flash[:notice] = I18n.t("proposals.update.success", scope: "decidim")
      #       redirect_to Decidim::ResourceLocatorPresenter.new(proposal).path
      #     end

      #     on(:invalid) do
      #       flash.now[:alert] = I18n.t("proposals.update.error", scope: "decidim")
      #       render :edit
      #     end
      #   end
      # end

      private

      def search_klass
        CollaborativeDraftSearch
      end

      def default_filter_params
        {
          search_text: "",
          category_id: "",
          state: "open",
          scope_id: nil,
          related_to: ""
        }
      end
    end
  end
end
