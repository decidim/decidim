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
      before_action :authenticate_user!, only: [:new, :create]

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
                               author: current_user,
                               proposal: @proposals.pluck(:id)
                             ).pluck(:decidim_proposal_id)
                           else
                             []
                           end

        @proposals = paginate(@proposals)
        @proposals = reorder(@proposals)
      end

      def show
        @proposal = Proposal.published.not_hidden.where(feature: current_feature).find(params[:id])
        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")
      end

      def new
        authorize! :create, Proposal
        @step = :step_1
        if proposal_draft.present?
          redirect_to edit_draft_proposal_path proposal_draft.id
        else
          @form = form(ProposalForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end
      end

      def create
        authorize! :create, Proposal

        @form = form(ProposalForm).from_params(params)

        CreateProposal.call(@form, current_user) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")
            redirect_to compare_proposal_path(proposal)
            # redirect_to Decidim::ResourceLocatorPresenter.new(proposal).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            render :new
          end
        end
      end

      def compare
        @step = :step_2
        @proposal = Proposal.not_hidden.where(feature: current_feature).find(params[:id])
        @similar_proposals ||= Decidim::Proposals::SimilarProposals
                                 .for(current_feature, @proposal)
                                 .all

        unless @similar_proposals.present?
          flash[:notice] = I18n.t("proposals.proposals.compare.no_similars_found", scope: "decidim")
          redirect_to preview_proposal_path(@proposal)
        end
      end

      def preview
        @step = :step_3
        @proposal = Proposal.not_hidden.where(feature: current_feature).find(params[:id])
      end

      def publish
        @proposal = Proposal.not_hidden.where(feature: current_feature).find(params[:id])
        PublishProposal.call(@proposal, current_user) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.publish.success", scope: "decidim")
            redirect_to proposal_path(proposal)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.publish.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def edit_draft
        @step = :step_1
        @proposal = Proposal.not_hidden.where(feature: current_feature).find(params[:id])
        authorize! :edit, Proposal

        @form = form(ProposalForm).from_model(@proposal)
      end

      def update_draft
        @proposal = Proposal.not_hidden.where(feature: current_feature).find(params[:id])
        # authorize! :edit, @proposal

        @form = form(ProposalForm).from_params(params)
        UpdateProposal.call(@form, current_user, @proposal) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.update.success", scope: "decidim")
            redirect_to preview_proposal_path(proposal)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.update.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def edit
        @proposal = Proposal.published.not_hidden.where(feature: current_feature).find(params[:id])
        authorize! :edit, @proposal

        @form = form(ProposalForm).from_model(@proposal)
      end

      def update
        @proposal = Proposal.not_hidden.where(feature: current_feature).find(params[:id])
        authorize! :edit, @proposal

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
        @proposal = Proposal.published.not_hidden.where(feature: current_feature).find(params[:id])
        authorize! :withdraw, @proposal

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
          origin: "all",
          activity: "",
          category_id: "",
          state: "not_withdrawn",
          scope_id: nil,
          related_to: ""
        }
      end

      def proposal_draft
        Proposal.not_hidden.where(feature: current_feature).find_by(published_at: nil)
      end
    end
  end
end
