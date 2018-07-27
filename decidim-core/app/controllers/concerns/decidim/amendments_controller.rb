# frozen_string_literal: true

module Decidim
  class AmendmentsController < Decidim::ApplicationController
    include FormFactory
    before_action :authenticate_user!
    helper_method :amendable

    def new
      @form = form(Decidim::CreateAmendForm).from_params(params)
      @form.title = amendable.title
      @form.body = amendable.body
    end

    def create
      @form = form(Decidim::CreateAmendForm).from_params(params)
      enforce_permission_to :create, :amend


      Decidim::CreateAmend.call(@form) do
        on(:ok) do
          redirect_to Decidim::ResourceLocatorPresenter.new(@amendable).path
        end

        on(:invalid) do
          raise
          render json: { error: I18n.t("amendments.create.error", scope: "decidim") }, status: 422
        end
      end
    end

    def reject
      @form = form(Decidim::RejectAmendForm).from_params(params)
      enforce_permission_to :reject, :amend, amend: @form.amendable

      RejectAmend.call(@form, current_user) do
        on(:ok) do
          render :update_button
        end

        on(:invalid) do
          render json: { error: I18n.t("amendments.reject.error", scope: "decidim") }, status: 422
        end
      end
    end

    def accept
      @form = form(Decidim::AcceptAmendForm).from_params(params)
      enforce_permission_to :accept, :amend, amend: @form.amendable

      AcceptAmend.call(@form, current_user) do
        on(:ok) do
          render :update_button
        end

        on(:invalid) do
          render json: { error: I18n.t("amendments.accept.error", scope: "decidim") }, status: 422
        end
      end
    end

    def amendable_gid
      params[:amendable_gid]
    end

    def amendable
      # @amendable ||= @form.amendable
      @amendable ||= GlobalID::Locator.locate_signed amendable_gid
    end
  end
end
