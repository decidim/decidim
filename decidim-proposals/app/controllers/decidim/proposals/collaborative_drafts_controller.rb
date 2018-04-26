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
      before_action :authenticate_user!, only: [:new, :create, :complete]

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

      def new
        authorize! :create, CollaborativeDraft
        @step = :step_1
        @form = form(CollaborativeDraftForm).from_params(
          attachment: form(AttachmentForm).from_params({})
        )
      end

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

      def compare
        @step = :step_2
        @similar_collaborative_drafts ||= Decidim::Proposals::SimilarCollaborativeDrafts
                                          .for(current_component, params[:collaborative_draft])
                                          .all
        @form = form(CollaborativeDraftForm).from_params(params)

        if @similar_collaborative_drafts.blank?
          flash[:notice] = I18n.t("proposals.collaborative_drafts.compare.no_similars_found", scope: "decidim")
          redirect_to complete_collaborative_drafts_path(collaborative_draft: { title: @form.title, body: @form.body })
        end
      end

      def complete
        authorize! :create, CollaborativeDraft
        @step = :step_3
        if params[:collaborative_draft].present?
          params[:collaborative_draft][:attachment] = form(AttachmentForm).from_params({})
          @form = form(CollaborativeDraftForm).from_params(params)
        else
          @form = form(CollaborativeDraftForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end
      end

      def create
        authorize! :create, CollaborativeDraft
        @step = :step_3
        @form = form(CollaborativeDraftForm).from_params(params)

        CreateCollaborativeDraft.call(@form, current_user) do
          on(:ok) do |collaborative_draft|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")

            # redirect_to Decidim::ResourceLocatorPresenter.new(collaborative_draft).path + "/preview"
            redirect_to preview_collaborative_draft_path collaborative_draft
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            render :complete
          end
        end
      end

      def preview
        @collaborative_draft = CollaborativeDraft.where(component: current_component).find(params[:id])
        @step = :step_4
      end

      def publish
        @step = :step_4
        PublishCollaborativeDraft.call(@collaborative_draft, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("proposals.publish.success", scope: "decidim")
            redirect_to collaborative_draft_path(@collaborative_draft)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.publish.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def edit_draft
        @step = :step_3
        authorize! :edit, CollaborativeDraft

        @form = form(CollaborativeDraftForm).from_model(@collaborative_draft)
      end

      # def update_draft
      #   @step = :step_1
      #   authorize! :edit, @collaborative_draft

      #   @form = form(ProposalForm).from_params(params)
      #   UpdateProposal.call(@form, current_user, @collaborative_draft) do
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
      #   @collaborative_draft = Proposal.published.not_hidden.where(component: current_component).find(params[:id])
      #   authorize! :edit, @collaborative_draft

      #   @form = form(ProposalForm).from_model(@collaborative_draft)
      # end

      # def update
      #   @collaborative_draft = Proposal.not_hidden.where(component: current_component).find(params[:id])
      #   authorize! :edit, @collaborative_draft

      #   @form = form(ProposalForm).from_params(params)
      #   UpdateProposal.call(@form, current_user, @collaborative_draft) do
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
