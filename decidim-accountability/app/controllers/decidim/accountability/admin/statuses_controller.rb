# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class StatusesController < Admin::ApplicationController
        helper_method :statuses

        def new
          enforce_permission_to :create, :status

          @form = form(StatusForm).instance
        end

        def create
          enforce_permission_to :create, :status

          @form = form(StatusForm).from_params(params)

          CreateStatus.call(@form, current_user) do
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
          enforce_permission_to :update, :status, status: status

          @form = form(StatusForm).from_model(status)
        end

        def update
          enforce_permission_to :update, :status, status: status

          @form = form(StatusForm).from_params(params)

          UpdateStatus.call(@form, status, current_user) do
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
          enforce_permission_to :destroy, :status, status: status

          Decidim.traceability.perform_action!("delete", status, current_user) do
            status.destroy!
          end

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
