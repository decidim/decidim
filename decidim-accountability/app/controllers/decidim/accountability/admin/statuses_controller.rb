# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class StatusesController < Admin::ApplicationController
        include Decidim::Accountability::Admin::Filterable

        helper_method :statuses

        def new
          enforce_permission_to :create, :status

          @form = form(StatusForm).instance
        end

        def create
          enforce_permission_to :create, :status

          @form = form(StatusForm).from_params(params)

          CreateStatus.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("statuses.create.success", scope: "decidim.accountability.admin")
              redirect_to statuses_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("statuses.create.invalid", scope: "decidim.accountability.admin")
              render action: "new", status: :unprocessable_entity
            end
          end
        end

        def edit
          enforce_permission_to(:update, :status, status:)

          @form = form(StatusForm).from_model(status)
        end

        def update
          enforce_permission_to(:update, :status, status:)

          @form = form(StatusForm).from_params(params)

          UpdateStatus.call(@form, status) do
            on(:ok) do
              flash[:notice] = I18n.t("statuses.update.success", scope: "decidim.accountability.admin")
              redirect_to statuses_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("statuses.update.invalid", scope: "decidim.accountability.admin")
              render action: "edit", status: :unprocessable_entity
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :status, status:)

          Decidim::Commands::DestroyResource.call(status, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("statuses.destroy.success", scope: "decidim.accountability.admin")
              redirect_to statuses_path
            end
          end
        end

        private

        def base_query
          Status.where(component: current_component)
        end

        def filtered_collection
          query.sorts = ["progress asc", "key asc"] if query.sorts.empty?

          paginate(query.result)
        end

        def statuses
          @statuses ||= filtered_collection
        end

        def status
          @status ||= statuses.find(params[:id])
        end
      end
    end
  end
end
