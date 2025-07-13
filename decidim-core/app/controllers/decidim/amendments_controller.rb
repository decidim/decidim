# frozen_string_literal: true

module Decidim
  class AmendmentsController < Decidim::ApplicationController
    include Decidim::ApplicationHelper
    include FormFactory
    include HasSpecificBreadcrumb
    helper Decidim::ResourceReferenceHelper

    before_action :authenticate_user!
    helper_method :amendment, :amendable, :emendation
    before_action :ensure_is_draft_from_user, only: [:edit_draft, :update_draft, :destroy_draft, :preview_draft, :publish_draft]

    def new
      raise ActionController::RoutingError, "Not Found" unless amendable

      enforce_permission_to :create, :amendment, current_component: amendable.component

      amendment_draft = amendable.amendments.find_by(amender: current_user.id, state: "draft")

      if amendment_draft
        redirect_to edit_draft_amend_path(amendment_draft)
      else
        @form = form(Decidim::Amendable::CreateForm).from_params(params)
      end
    end

    def create
      enforce_permission_to :create, :amendment, current_component: amendable.component

      @form = form(Decidim::Amendable::CreateForm).from_params(params)

      Decidim::Amendable::CreateDraft.call(@form) do
        on(:ok) do |amendment|
          flash[:notice] = t("created.success", scope: "decidim.amendments")
          redirect_to preview_draft_amend_path(amendment)
        end

        on(:invalid) do
          flash.now[:alert] = t("created.error", scope: "decidim.amendments")
          render :new
        end
      end
    end

    def edit_draft
      enforce_permission_to :create, :amendment, current_component: amendable.component

      @form = form(Decidim::Amendable::EditForm).from_model(amendment)
    end

    def update_draft
      enforce_permission_to :create, :amendment, current_component: amendable.component

      @form = form(Decidim::Amendable::EditForm).from_params(params)

      Decidim::Amendable::UpdateDraft.call(@form) do
        on(:ok) do |amendment|
          flash[:notice] = t("success", scope: "decidim.amendments.update_draft")
          redirect_to preview_draft_amend_path(amendment)
        end

        on(:invalid) do
          flash.now[:alert] = t("error", scope: "decidim.amendments.update_draft")
          render :edit_draft
        end
      end
    end

    def destroy_draft
      enforce_permission_to :create, :amendment, current_component: amendable.component

      Decidim::Amendable::DestroyDraft.call(amendment, current_user) do
        on(:ok) do |amendable|
          flash[:notice] = t("success", scope: "decidim.amendments.destroy_draft")
          redirect_to new_amend_path(amendable_gid: amendable.to_sgid.to_s)
        end

        on(:invalid) do
          flash[:alert] = t("error", scope: "decidim.amendments.destroy_draft")
          redirect_to edit_draft_amend_path(amendment)
        end
      end
    end

    def preview_draft
      enforce_permission_to :create, :amendment, current_component: amendable.component
    end

    def publish_draft
      enforce_permission_to :create, :amendment, current_component: amendable.component

      @form = form(Decidim::Amendable::PublishForm).from_model(amendment)

      Decidim::Amendable::PublishDraft.call(@form) do
        on(:ok) do |emendation|
          flash[:notice] = t("success", scope: "decidim.amendments.publish_draft")
          redirect_to Decidim::ResourceLocatorPresenter.new(emendation).path
        end

        on(:invalid) do
          flash.now[:alert] = t("error", scope: "decidim.amendments.publish_draft")
          render :edit_draft
        end
      end
    end

    def reject
      enforce_permission_to :reject, :amendment, current_component: amendable.component

      @form = form(Decidim::Amendable::RejectForm).from_model(amendment)

      Decidim::Amendable::Reject.call(@form) do
        on(:ok) do
          flash[:notice] = t("rejected.success", scope: "decidim.amendments")
        end

        on(:invalid) do
          flash[:alert] = t("rejected.error", scope: "decidim.amendments")
        end

        redirect_to Decidim::ResourceLocatorPresenter.new(emendation).path
      end
    end

    def promote
      enforce_permission_to :promote, :amendment, current_component: amendable.component

      @form = form(Decidim::Amendable::PromoteForm).from_model(amendment)

      Decidim::Amendable::Promote.call(@form) do
        on(:ok) do |promoted_resource|
          flash[:notice] = I18n.t("promoted.success", scope: "decidim.amendments")
          redirect_to Decidim::ResourceLocatorPresenter.new(promoted_resource).path
        end

        on(:invalid) do
          flash.now[:alert] = t("promoted.error", scope: "decidim.amendments")
          redirect_to Decidim::ResourceLocatorPresenter.new(emendation).path
        end
      end
    end

    def review
      enforce_permission_to :accept, :amendment, current_component: amendable.component

      @form = form(Decidim::Amendable::ReviewForm).from_params(params)
    end

    def accept
      enforce_permission_to :accept, :amendment, current_component: amendable.component

      @form = form(Decidim::Amendable::ReviewForm).from_params(params)

      Decidim::Amendable::Accept.call(@form) do
        on(:ok) do |emendation|
          flash[:notice] = t("accepted.success", scope: "decidim.amendments")
          redirect_to Decidim::ResourceLocatorPresenter.new(emendation).path
        end

        on(:invalid) do
          flash.now[:alert] = t("accepted.error", scope: "decidim.amendments")
          render :review
        end
      end
    end

    def withdraw
      enforce_permission_to :withdraw, :amendment, amendment:, current_component: amendable.component

      Decidim::Amendable::Withdraw.call(amendment, current_user) do
        on(:ok) do |withdrawn_emendation|
          flash[:notice] = t("success", scope: "decidim.amendments.withdraw")
          redirect_to Decidim::ResourceLocatorPresenter.new(withdrawn_emendation).path
        end

        on(:invalid) do
          flash[:alert] = t("error", scope: "decidim.amendments.withdraw")
          redirect_to Decidim::ResourceLocatorPresenter.new(emendation).path
        end
      end
    end

    private

    # GlobalID::SignedGlobalID parameter to locate the amendable resource.
    # Needed for actions :new and :create, when there is no amendment yet.
    def amendable_gid
      params[:amendable_gid] || params.dig(:amendment, :amendable_gid)
    end

    def amendment
      @amendment ||= Decidim::Amendment.find_by(id: params[:id])
    end

    def amendable
      @amendable ||= GlobalID::Locator.locate_signed(amendable_gid) || amendment&.amendable
    end

    def emendation
      @emendation ||= amendment&.emendation
    end

    def amender
      @amender ||= amendment&.amender
    end

    def ensure_is_draft_from_user
      raise ActionController::RoutingError, "Not Found" unless amendment.draft? && amender == current_user
    end

    def breadcrumb_item
      {
        label: t("decidim.amendments.name"),
        active: true
      }
    end
  end
end
