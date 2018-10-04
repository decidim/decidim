# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      helper ProposalWizardHelper
      include FormFactory
      include FilterResource
      include Orderable
      include Paginable

      helper_method :geocoded_proposals
      before_action :authenticate_user!, only: [:new, :create, :complete]
      before_action :ensure_is_draft, only: [:preview, :publish, :edit_draft, :update_draft, :destroy_draft]

      def index
        @proposals = search
                     .results
                     .published
                     .not_hidden
                     .includes(:author)
                     .includes(:category)
                     .includes(:scope)

        @voted_proposals = if current_user
                             ProposalVote.where(
                               author:   current_user,
                               proposal: @proposals.pluck(:id)
                             ).pluck(:decidim_proposal_id)
                           else
                             []
                           end

        @proposals = paginate(@proposals)
        @proposals = reorder(@proposals)
      end

      def show
        @proposal = Proposal
                    .published
                    .not_hidden
                    .where(component: current_component)
                    .find(params[:id])
        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")
      end

      def new
        enforce_permission_to :create, :proposal
        @step = :step_1
        if proposal_draft.present?
          redirect_to edit_draft_proposal_path(proposal_draft, component_id: proposal_draft.component.id, question_slug: proposal_draft.component.participatory_space.slug)
        else
          @form = form(ProposalForm).from_params(params)
        end
      end

      def create
        enforce_permission_to :create, :proposal
        @step = :step_3
        @form = form(ProposalForm).from_params(params)

        CreateProposal.call(@form, current_user) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")

            compare_path = Decidim::ResourceLocatorPresenter.new(proposal).path + "/preview"
            redirect_to compare_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            render :complete
          end
        end
      end

      def compare
        @step = :step_2
        @similar_proposals ||= Decidim::Proposals::SimilarProposals
                               .for(current_component, params[:proposal])
                               .all
        @form = form(ProposalForm).from_params(params)

        if @similar_proposals.blank?
          flash[:notice] = I18n.t("proposals.proposals.compare.no_similars_found", scope: "decidim")
          redirect_to complete_proposals_path(proposal: { title: @form.title, body: @form.body })
        end
      end

      def complete
        enforce_permission_to :create, :proposal
        @step = :step_3

        if params[:proposal].present?
          params[:proposal][:attachment] = form(AttachmentForm).from_params({})
          @form = form(ProposalForm).from_params(params)
        else
          @form = form(ProposalForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end
      end

      def preview
        @step = :step_4
        @form = form(ProposalForm).from_model(@proposal)
      end

      def publish
        @step = :step_4
        PublishProposal.call(@proposal, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("proposals.publish.success", scope: "decidim")
            redirect_to proposal_path(@proposal)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.publish.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def edit_draft
        @step = :step_3
        enforce_permission_to :edit, :proposal, proposal: @proposal

        @form = form(ProposalForm).from_model(@proposal)
      end

      def update_draft
        @step = :step_1
        enforce_permission_to :edit, :proposal, proposal: @proposal

        @form = form(ProposalForm).from_params(params)
        UpdateProposal.call(@form, current_user, @proposal) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.update_draft.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(proposal).path + "/preview"
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.update_draft.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def destroy_draft
        enforce_permission_to :edit, :proposal, proposal: @proposal

        DestroyProposal.call(@proposal, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("proposals.destroy_draft.success", scope: "decidim")
            redirect_to new_proposal_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.destroy_draft.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def edit
        @proposal = Proposal.published.not_hidden.where(component: current_component).find(params[:id])
        enforce_permission_to :edit, :proposal, proposal: @proposal

        @form = form(ProposalForm).from_model(@proposal)
      end

      def update
        @proposal = Proposal.not_hidden.where(component: current_component).find(params[:id])
        enforce_permission_to :edit, :proposal, proposal: @proposal

        @form = form(ProposalForm).from_params(params)
        UpdateProposal.call(@form, current_user, @proposal) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.update.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(proposal).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.update.error", scope: "decidim")
            render :edit
          end
        end
      end

      def withdraw
        @proposal = Proposal.published.not_hidden.where(component: current_component).find(params[:id])
        enforce_permission_to :withdraw, :proposal, proposal: @proposal

        WithdrawProposal.call(@proposal, current_user) do
          on(:ok) do |_proposal|
            flash[:notice] = I18n.t("proposals.update.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(@proposal).path
          end
          on(:invalid) do
            flash[:alert] = I18n.t("proposals.update.error", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(@proposal).path
          end
        end
      end

      private

      def geocoded_proposals
        @geocoded_proposals ||= search.results.not_hidden.select(&:geocoded?)
      end

      def search_klass
        ProposalSearch
      end

      def default_filter_params
        {
          search_text: "",
          origin:      "all",
          activity:    "",
          category_id: "",
          state:       "except_rejected",
          scope_id:    nil,
          related_to:  ""
        }
      end

      def proposal_draft
        Proposal.not_hidden.where(component: current_component, author: current_user).find_by(published_at: nil)
      end

      def ensure_is_draft
        @proposal = Proposal.not_hidden.where(component: current_component).find(params[:id])
        redirect_to Decidim::ResourceLocatorPresenter.new(@proposal).path unless @proposal.draft?
      end
    end
  end
end
