# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class ResultsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::SanitizeHelper
        include Decidim::Accountability::Admin::Filterable

        helper_method :results, :deleted_results, :parent_result, :parent_results, :statuses, :present

        def collection
          parent_id = params[:parent_id].presence
          @collection ||= Result.where(component: current_component, parent_id:).page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :create, :result

          @form = form(ResultForm).instance
          @form.parent_id = params[:parent_id]
        end

        def create
          enforce_permission_to :create, :result

          @form = form(ResultForm).from_params(params)

          CreateResult.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("results.create.success", scope: "decidim.accountability.admin")
              redirect_to results_path(parent_id: result.parent_id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("results.create.invalid", scope: "decidim.accountability.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to(:update, :result, result:)

          @form = form(ResultForm).from_model(result)
        end

        def update
          enforce_permission_to(:update, :result, result:)

          @form = form(ResultForm).from_params(params)

          UpdateResult.call(@form, result) do
            on(:ok) do
              flash[:notice] = I18n.t("results.update.success", scope: "decidim.accountability.admin")
              redirect_to results_path(parent_id: result.parent_id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("results.update.invalid", scope: "decidim.accountability.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :result, result:)

          Decidim::Commands::DestroyResource.call(result, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.destroy.success", scope: "decidim.accountability.admin")

              redirect_to results_path(parent_id: result.parent_id)
            end
          end
        end

        def soft_delete
          enforce_permission_to(:soft_delete, :result, result:)

          Decidim::Commands::SoftDeleteResource.call(result, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.soft_delete.success", scope: "decidim.accountability.admin")

              redirect_to results_path(parent_id: result.parent_id)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("results.soft_delete.invalid", scope: "decidim.accountability.admin")

              redirect_to deleted_results_path
            end
          end
        end

        def restore
          enforce_permission_to(:restore, :result, result:)

          Decidim::Commands::RestoreResource.call(result, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.restore.success", scope: "decidim.accountability.admin")

              redirect_to results_path(parent_id: result.parent_id)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("results.restore.invalid", scope: "decidim.accountability.admin")

              redirect_to deleted_results_path
            end
          end
        end

        def deleted
          enforce_permission_to(:deleted, :result)
        end

        private

        def results
          @results ||= filtered_collection.not_deleted
        end

        def deleted_results
          @deleted_results ||= filtered_collection.trashed
        end

        def result
          @result ||= Result.where(component: current_component).find(params[:id])
        end

        def parent_result
          @parent_result ||= Result.find_by(component: current_component, id: params[:parent_id])
        end

        def parent_results
          @parent_results ||= Result.where(component: current_component, parent_id: nil)
        end

        def statuses
          @statuses ||= Status.where(component: current_component)
        end
      end
    end
  end
end
