# frozen_string_literal: true

module Decidim
  class AmendmentsController < Decidim::ApplicationController
    include Decidim::ApplicationHelper
    include FormFactory

    before_action :authenticate_user!
    helper_method :amendable, :emendation

    def new
      @form = Decidim::Amendable::CreateForm.from_params(
        amendable_gid: params[:amendable_gid],
        emendation_gid: params[:emedation_gid],
        emendation_fields: emendation_fields_form
      ).with_context(form_context)
    end

    def create
      @form = form(Decidim::Amendable::CreateForm).from_params(params)
      enforce_permission_to :create, :amend
      return unless validate(@form)

      Decidim::Amendable::Create.call(@form) do
        on(:ok) do
          flash[:notice] = t("created.success", scope: "decidim.amendments")
          redirect_to Decidim::ResourceLocatorPresenter.new(@amendable).path
        end

        on(:invalid) do
          flash[:alert] = t("created.error", scope: "decidim.amendments")
          render :new
        end
      end
    end

    def reject
      @form = form(Decidim::Amendable::RejectForm).from_params(params)
      enforce_permission_to :reject, :amend, amend: @form.amendable

      Decidim::Amendable::Reject.call(@form) do
        on(:ok) do
          flash[:notice] = t("rejected.success", scope: "decidim.amendments")
        end

        on(:invalid) do
          flash[:alert] = t("rejected.error", scope: "decidim.amendments")
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@emendation).path
      end
    end

    def promote
      @form = Decidim::Amendable::PromoteForm.from_params(
        id: params[:id],
        emendation_fields: emendation_fields_form
      ).with_context(form_context)

      Decidim::Amendable::Promote.call(@form) do
        on(:ok) do |proposal|
          flash[:notice] = I18n.t("promoted.success", scope: "decidim.amendments")
          redirect_to Decidim::ResourceLocatorPresenter.new(proposal).path
        end

        on(:invalid) do
          flash.now[:alert] = t("promoted.error", scope: "decidim.amendments")
          redirect_to Decidim::ResourceLocatorPresenter.new(@emendation).path
        end
      end
    end

    def review; end

    def accept; end

    private

    def emendation_fields_form
      amendable.form.from_model(amendable).with_context(form_context)
    end

    def form_context
      {
        current_organization: amendable.organization,
        current_component: amendable.component,
        current_user: current_user,
        current_participatory_space: amendable.participatory_space
      }
    end

    def amendable_gid
      params[:amendable_gid]
    end

    def amendable
      @amendable ||= if params[:amendable_gid]
                       present(GlobalID::Locator.locate_signed(amendable_gid))
                     else
                       Decidim::Amendment.find_by(decidim_emendation_id: params[:id]).amendable
                     end
    end

    def emendation
      @emendation ||= present(Decidim::Amendment.find(params[:id]).emendation)
    end

    def validate(form)
      Decidim::Amendable::Validate.call(form) do
        on(:ok) do
          true
        end

        on(:invalid) do
          flash[:alert] = t("created.error", scope: "decidim.amendments")
          params[:amend][:emendation_fields] = params[:amend][:emendation_fields]
          redirect_to new_amend_path(amendable_gid: @form.amendable_gid)
          return false
        end
      end
    end
  end
end
