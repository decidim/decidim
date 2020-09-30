# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes Collaborative Drafts resource so users can view and create them.
    class CollaborativeDraftsController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      helper ProposalWizardHelper
      helper TooltipHelper

      include Decidim::ApplicationHelper
      include FormFactory
      include Flaggable
      include FilterResource
      include CollaborativeOrderable
      include Paginable

      helper_method :form_presenter

      helper_method :geocoded_collaborative_draft, :collaborative_draft
      before_action :collaborative_drafts_enabled?
      before_action :authenticate_user!, only: [:new, :create, :complete]
      before_action :retrieve_collaborative_draft, only: [:show, :edit, :update, :withdraw, :publish]

      def index
        @collaborative_drafts = search
                                .results
                                .not_hidden
                                .includes(:category)
                                .includes(:scope)

        @collaborative_drafts = paginate(@collaborative_drafts)
        @collaborative_drafts = reorder(@collaborative_drafts)
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless retrieve_collaborative_draft

        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")
        @request_access_form = form(RequestAccessToCollaborativeDraftForm).from_params({})
        @accept_request_form = form(AcceptAccessToCollaborativeDraftForm).from_params({})
        @reject_request_form = form(RejectAccessToCollaborativeDraftForm).from_params({})
      end

      def new
        enforce_permission_to :create, :collaborative_draft
        @step = :step_1

        @form = form(CollaborativeDraftForm).from_params(
          attachment: form(AttachmentForm).from_params({})
        )
      end

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
        enforce_permission_to :create, :collaborative_draft
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
        enforce_permission_to :create, :collaborative_draft
        @step = :step_3
        @form = form(CollaborativeDraftForm).from_params(params)

        CreateCollaborativeDraft.call(@form, current_user) do
          on(:ok) do |collaborative_draft|
            flash[:notice] = I18n.t("proposals.collaborative_drafts.create.success", scope: "decidim")

            redirect_to Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.collaborative_drafts.create.error", scope: "decidim")
            render :complete
          end
        end
      end

      def edit
        enforce_permission_to :edit, :collaborative_draft, collaborative_draft: @collaborative_draft

        @form = form(CollaborativeDraftForm).from_model(@collaborative_draft)
        @form.attachment = form(AttachmentForm).from_model(@collaborative_draft.attachments.first)
      end

      def update
        enforce_permission_to :edit, :collaborative_draft, collaborative_draft: @collaborative_draft

        @form = form(CollaborativeDraftForm).from_params(params)
        UpdateCollaborativeDraft.call(@form, current_user, @collaborative_draft) do
          on(:ok) do |collaborative_draft|
            flash[:notice] = I18n.t("proposals.collaborative_drafts.update.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.collaborative_drafts.update.error", scope: "decidim")
            render :edit
          end
        end
      end

      def withdraw
        WithdrawCollaborativeDraft.call(@collaborative_draft, current_user) do
          on(:ok) do
            flash[:notice] = t("withdraw.success", scope: "decidim.proposals.collaborative_drafts.collaborative_draft")
          end

          on(:invalid) do
            flash.now[:alert] = t("withdraw.error", scope: "decidim.proposals.collaborative_drafts.collaborative_draft")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@collaborative_draft).path
      end

      def publish
        PublishCollaborativeDraft.call(@collaborative_draft, current_user) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("publish.success", scope: "decidim.proposals.collaborative_drafts.collaborative_draft")
            redirect_to Decidim::ResourceLocatorPresenter.new(proposal).path
          end

          on(:invalid) do
            flash.now[:alert] = t("publish.error", scope: "decidim.proposals.collaborative_drafts.collaborative_draft")
            redirect_to Decidim::ResourceLocatorPresenter.new(@collaborative_draft).path
          end
        end
      end

      private

      def form_presenter
        @form_presenter ||= present(@form, presenter_class: Decidim::Proposals::CollaborativeDraftPresenter)
      end

      def collaborative_drafts_enabled?
        raise ActionController::RoutingError, "Not Found" unless component_settings.collaborative_drafts_enabled?
      end

      def retrieve_collaborative_draft
        @collaborative_draft = CollaborativeDraft.not_hidden.where(component: current_component).find_by(id: params[:id])
      end

      def geocoded_collaborative_draft
        @geocoded_collaborative_draft ||= search.results.not_hidden.select(&:geocoded?)
      end

      def search_klass
        CollaborativeDraftSearch
      end

      def default_filter_params
        {
          search_text: "",
          category_id: default_filter_category_params,
          state: %w(open),
          scope_id: default_filter_scope_params,
          related_to: ""
        }
      end

      def default_filter_category_params
        return unless current_component.participatory_space.categories.any?

        ["without"] + current_component.participatory_space.categories.map { |category| category.id.to_s }
      end
    end
  end
end
