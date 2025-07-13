# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class ResultsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::SanitizeHelper
        include Decidim::Admin::ComponentTaxonomiesHelper
        include Decidim::Accountability::Admin::Filterable
        include Decidim::Admin::HasTrashableResources

        helper_method :results, :parent_result, :parent_results, :statuses, :present, :bulk_actions_form

        def collection
          parent_id = params[:parent_id].presence
          @collection ||= Result.where(component: current_component, parent_id:).page(params[:page]).per(15).order(created_at: :asc)
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

        private

        def trashable_deleted_resource_type
          :result
        end

        def trashable_deleted_resource
          @trashable_deleted_resource ||= Result.with_deleted.where(component: current_component).find_by(id: params[:id])
        end

        def trashable_deleted_collection
          @trashable_deleted_collection = filtered_collection.only_deleted.deleted_at_desc
        end

        def find_parent_resource
          parent_result
        end

        def results
          @results ||= filtered_collection
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

        def bulk_actions_form
          @bulk_actions_form ||= ResultBulkActionsForm.new(result_ids: [])
        end
      end
    end
  end
end
