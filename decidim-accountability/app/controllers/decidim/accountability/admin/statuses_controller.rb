# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class StatusesController < Admin::ApplicationController
        helper_method :statuses

        def new
          @form = form(StatusForm).instance
        end

        def create
          @form = form(StatusForm).from_params(params)

          CreateStatus.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("statuses.create.success", scope: "decidim.accountability.admin")
              redirect_to statuses_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("statuses.create.invalid", scope: "decidim.accountability.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = form(StatusForm).from_model(status)
        end

        def update
          @form = form(StatusForm).from_params(params)

          UpdateStatus.call(@form, status) do
            on(:ok) do
              flash[:notice] = I18n.t("statuses.update.success", scope: "decidim.accountability.admin")
              redirect_to statuses_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("statuses.update.invalid", scope: "decidim.accountability.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          status.destroy!

          flash[:notice] = I18n.t("statuses.destroy.success", scope: "decidim.accountability.admin")

          redirect_to statuses_path
        end

        private

        def statuses
          @statuses ||= Status.where(component: current_component).page(params[:page]).per(15)
        end

        def status
          @status ||= statuses.find(params[:id])
        end
      end
    end
  end
end
