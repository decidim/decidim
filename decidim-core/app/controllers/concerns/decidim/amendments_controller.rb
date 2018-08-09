# frozen_string_literal: true

module Decidim
  class AmendmentsController < Decidim::ApplicationController
    include FormFactory
    before_action :authenticate_user!
    helper_method :amendable, :emendation

    def new
      @form = form(Decidim::Amendable::CreateForm).from_model(amendable)
      @form.amendable_gid = params[:amendable_gid]
    end

    def create
      @form = form(Decidim::Amendable::CreateForm).from_params(params)
      enforce_permission_to :create, :amend

      Decidim::Amendable::Create.call(@form) do
        on(:ok) do
          redirect_to Decidim::ResourceLocatorPresenter.new(@amendable).path
        end

        on(:invalid) do
          redirect_to Decidim::ResourceLocatorPresenter.new(@amendable).path
          render json: { error: I18n.t("amendments.create.error", scope: "decidim") }, status: 422
        end
      end
    end

    def reject
    end

    def review
    end

    def accept
    end

    def amendable_gid
      params[:amendable_gid]
    end

    def amendable
      @amendable ||= GlobalID::Locator.locate_signed amendable_gid
    end

    def emendation
      @emendation ||= Decidim::Amendment.find(params[:id]).emendation
    end
  end
end
