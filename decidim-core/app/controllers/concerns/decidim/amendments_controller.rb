# frozen_string_literal: true

module Decidim
  class AmendmentsController < Decidim::ApplicationController
    include FormFactory
    before_action :authenticate_user!
    helper_method :amendable, :emendation

    def new
      form_context = {
        current_user: current_user,
        current_participatory_space: amendable.participatory_space,
        participatory_space: amendable.participatory_space,
        component: amendable.component
      }

      emendation_fields_form = amendable.form.from_model(amendable).with_context(form_context)

      @form = Decidim::Amendable::CreateForm.from_params(
        amendable_gid: params[:amendable_gid],
        emendation_fields: emendation_fields_form
      ).with_context(form_context)
    end

    def create
      @form = form(Decidim::Amendable::CreateForm).from_params(params)
      enforce_permission_to :create, :amend

      Decidim::Amendable::Create.call(@form) do
        on(:ok) do
          flash[:notice] = t("created.success", scope: "decidim.amendments")
        end

        on(:invalid) do
          flash[:alert] = t("created.error", scope: "decidim.amendments")
        end

        redirect_to Decidim::ResourceLocatorPresenter.new(@amendable).path
      end
    end

    def reject; end

    def review; end

    def accept; end

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
