# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      helper ProposalWizardHelper
      helper ParticipatoryTextsHelper
      helper UserGroupHelper
      include Decidim::ApplicationHelper
      include Flaggable
      include Withdrawable
      include FormFactory
      include FilterResource
      include Decidim::Proposals::Orderable
      include Paginable

      helper_method :proposal_presenter, :form_presenter

      before_action :authenticate_user!, only: [:new, :create, :complete]
      before_action :ensure_is_draft, only: [:compare, :complete, :preview, :publish, :edit_draft, :update_draft, :destroy_draft]
      before_action :set_proposal, only: [:show, :edit, :update, :withdraw]
      before_action :edit_form, only: [:edit_draft, :edit]

      before_action :set_participatory_text

      # rubocop:disable Naming/VariableNumber
      STEP1 = :step_1
      STEP2 = :step_2
      STEP3 = :step_3
      STEP4 = :step_4
      # rubocop:enable Naming/VariableNumber

      def index
        if component_settings.participatory_texts_enabled?
          @proposals = Decidim::Proposals::Proposal
                       .where(component: current_component)
                       .published
                       .not_hidden
                       .only_amendables
                       .includes(:category, :scope, :attachments, :coauthorships)
                       .order(position: :asc)
          render "decidim/proposals/proposals/participatory_texts/participatory_text"
        else
          @base_query = search
                        .result
                        .published
                        .not_hidden

          @proposals = @base_query.includes(:component, :coauthorships, :attachments)
          @all_geocoded_proposals = @base_query.geocoded

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
      end

      def show
        raise ActionController::RoutingError, "Not Found" if @proposal.blank? || !can_show_proposal?
      end

      def new
        enforce_permission_to :create, :proposal
        @step = STEP1
        if proposal_draft.present?
          redirect_to edit_draft_proposal_path(proposal_draft, component_id: proposal_draft.component.id, question_slug: proposal_draft.component.participatory_space.slug)
        else
          @form = form(ProposalWizardCreateStepForm).from_params(body: translated_proposal_body_template)
        end
      end

      def create
        enforce_permission_to :create, :proposal
        @step = STEP1
        @form = form(ProposalWizardCreateStepForm).from_params(proposal_creation_params)

        CreateProposal.call(@form, current_user) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")

            redirect_to "#{Decidim::ResourceLocatorPresenter.new(proposal).path}/compare"
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            render :new
          end
        end
      end

      def compare
        enforce_permission_to :edit, :proposal, proposal: @proposal
        @step = STEP2
        @similar_proposals ||= Decidim::Proposals::SimilarProposals
                               .for(current_component, @proposal)
                               .all

        if @similar_proposals.blank?
          flash[:notice] = I18n.t("proposals.proposals.compare.no_similars_found", scope: "decidim")
          redirect_to "#{Decidim::ResourceLocatorPresenter.new(@proposal).path}/complete"
        end
      end

      def complete
        enforce_permission_to :edit, :proposal, proposal: @proposal
        @step = STEP3

        @form = form_proposal_model

        @form.attachment = form_attachment_new
      end

      def preview
        enforce_permission_to :edit, :proposal, proposal: @proposal
        @step = STEP4
        @form = form(ProposalForm).from_model(@proposal)
      end

      def publish
        enforce_permission_to :edit, :proposal, proposal: @proposal
        @step = STEP4
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
        @step = STEP3
        enforce_permission_to :edit, :proposal, proposal: @proposal
      end

      def update_draft
        @step = STEP1
        enforce_permission_to :edit, :proposal, proposal: @proposal

        @form = form_proposal_params
        UpdateProposal.call(@form, current_user, @proposal) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.update_draft.success", scope: "decidim")
            redirect_to "#{Decidim::ResourceLocatorPresenter.new(proposal).path}/preview"
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
        enforce_permission_to :edit, :proposal, proposal: @proposal
      end

      def update
        enforce_permission_to :edit, :proposal, proposal: @proposal

        @form = form_proposal_params
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
        enforce_permission_to :withdraw, :proposal, proposal: @proposal

        WithdrawProposal.call(@proposal, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("proposals.update.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(@proposal).path
          end
          on(:has_supports) do
            flash[:alert] = I18n.t("proposals.withdraw.errors.has_supports", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(@proposal).path
          end
        end
      end

      private

      def search_collection
        Proposal.where(component: current_component).published.not_hidden.with_availability(params[:filter].try(:[], :with_availability))
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_origin: default_filter_origin_params,
          activity: "all",
          with_any_category: default_filter_category_params,
          with_any_state: %w(accepted evaluating state_not_published),
          with_any_scope: default_filter_scope_params,
          related_to: "",
          type: "all"
        }
      end

      def default_filter_origin_params
        filter_origin_params = %w(participants meeting)
        filter_origin_params << "official" if component_settings.official_proposals_enabled
        filter_origin_params << "user_group" if current_organization.user_groups_enabled?
        filter_origin_params
      end

      def proposal_draft
        Proposal.from_all_author_identities(current_user).not_hidden.only_amendables
                .where(component: current_component).find_by(published_at: nil)
      end

      def ensure_is_draft
        @proposal = Proposal.not_hidden.where(component: current_component).find(params[:id])
        redirect_to Decidim::ResourceLocatorPresenter.new(@proposal).path unless @proposal.draft?
      end

      def set_proposal
        @proposal = Proposal.published.not_hidden.where(component: current_component).find_by(id: params[:id])
      end

      # Returns true if the proposal is NOT an emendation or the user IS an admin.
      # Returns false if the proposal is not found or the proposal IS an emendation
      # and is NOT visible to the user based on the component's amendments settings.
      def can_show_proposal?
        return true if @proposal&.amendable? || current_user&.admin?

        Proposal.only_visible_emendations_for(current_user, current_component).published.include?(@proposal)
      end

      def proposal_presenter
        @proposal_presenter ||= present(@proposal)
      end

      def form_proposal_params
        form(ProposalForm).from_params(params)
      end

      def form_proposal_model
        form(ProposalForm).from_model(@proposal)
      end

      def form_presenter
        @form_presenter ||= present(@form, presenter_class: Decidim::Proposals::ProposalPresenter)
      end

      def form_attachment_new
        form(AttachmentForm).from_model(Attachment.new)
      end

      def edit_form
        form_attachment_model = form(AttachmentForm).from_model(@proposal.attachments.first)
        @form = form_proposal_model
        @form.attachment = form_attachment_model
        @form
      end

      def set_participatory_text
        @participatory_text = Decidim::Proposals::ParticipatoryText.find_by(component: current_component)
      end

      def translated_proposal_body_template
        translated_attribute component_settings.new_proposal_body_template
      end

      def proposal_creation_params
        params[:proposal].merge(body_template: translated_proposal_body_template)
      end
    end
  end
end
