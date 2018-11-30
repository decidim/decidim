# frozen_string_literal: true

module Decidim
  class AmendmentsController < Decidim::ApplicationController
    include Decidim::ApplicationHelper
    include FormFactory

    before_action :authenticate_user!
    helper_method :amendable, :emendation

    def new
      @form = Decidim::Amendable::CreateForm.from_params(params)
    end

    def create
      @form = form(Decidim::Amendable::CreateForm).from_params(params)
      enforce_permission_to :create, :amend

      Decidim::Amendable::Create.call(@form) do
        on(:ok) do
          flash[:notice] = t("created.success", scope: "decidim.amendments")
          redirect_to Decidim::ResourceLocatorPresenter.new(@amendable).path
        end

        on(:invalid) do
          flash[:alert] = t("created.error", scope: "decidim.amendments")
          redirect_to new_amend_path(amendable_gid: @form.amendable_gid)
        end
      end
    end

    def reject; end

    def review
      @form = Decidim::Amendable::ReviewForm.from_params(params)
    end

    def accept
      @form = Decidim::Amendable::ReviewForm.from_params(params)
      enforce_permission_to :accept, :amend, amend: @form.amendable

      Decidim::Amendable::Accept.call(@form) do
        on(:ok) do
          flash[:notice] = t("accepted.success", scope: "decidim.amendments")
          redirect_to Decidim::ResourceLocatorPresenter.new(@emendation).path
        end

        on(:invalid) do
          flash[:alert] = t("accepted.error", scope: "decidim.amendments")
          redirect_to review_amend_path(id: params[:id])
        end
      end
    end

    private

    def amendable_gid
      params[:amendable_gid]
    end

    def amendable
      @amendable ||= present(GlobalID::Locator.locate_signed(amendable_gid))
    end

    def emendation
      @emendation ||= present(Decidim::Amendment.find(params[:id]).emendation)
    end
  end
end
