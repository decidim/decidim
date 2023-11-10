# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This controller allows an admin to manage projects from a Participatory Process
      class ProjectsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Budgets::Admin::Filterable
        helper Decidim::Budgets::Admin::ProjectBulkActionsHelper
        helper Decidim::Budgets::ProjectsHelper

        helper_method :projects, :finished_orders, :pending_orders, :present, :project_ids

        def collection
          @collection ||= budget.projects.page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :create, :project
          @form = form(ProjectForm).from_params(
            attachment: form(AttachmentForm).instance
          )
        end

        def create
          enforce_permission_to :create, :project

          @form = form(ProjectForm).from_params(params, budget:)

          CreateProject.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("projects.create.success", scope: "decidim.budgets.admin")
              redirect_to budget_projects_path(budget)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("projects.create.invalid", scope: "decidim.budgets.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to(:update, :project, project:)
          @form = form(ProjectForm).from_model(project)
          @form.attachment = form(AttachmentForm).instance
        end

        def update
          enforce_permission_to(:update, :project, project:)
          @form = form(ProjectForm).from_params(params, budget:)

          UpdateProject.call(@form, project) do
            on(:ok) do
              flash[:notice] = I18n.t("projects.update.success", scope: "decidim.budgets.admin")
              redirect_to budget_projects_path(budget)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("projects.update.invalid", scope: "decidim.budgets.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :project, project:)

          DestroyProject.call(project, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("projects.destroy.success", scope: "decidim.budgets.admin")
              redirect_to budget_projects_path(budget)
            end
          end
        end

        def update_category
          enforce_permission_to :update, :project_category

          ::Decidim::Budgets::Admin::UpdateProjectCategory.call(params[:category][:id], project_ids) do
            on(:invalid_category) do
              flash.now[:error] = I18n.t(
                "projects.update_category.select_a_category",
                scope: "decidim.budgets.admin"
              )
            end

            on(:invalid_project_ids) do
              flash.now[:alert] = I18n.t(
                "projects.update_category.select_a_project",
                scope: "decidim.budgets.admin"
              )
            end

            on(:update_projects_category) do
              flash.now[:notice] = update_projects_bulk_response_successful(@response, :category)
              flash.now[:alert] = update_projects_bulk_response_errored(@response, :category)
            end
          end

          respond_to do |format|
            format.js { render :update_attribute, locals: { form_selector: "#js-form-recategorize-projects", attribute_selector: "#category_id" } }
          end
        end

        def update_scope
          enforce_permission_to :update, :project_scope

          ::Decidim::Budgets::Admin::UpdateProjectScope.call(params[:scope_id], project_ids) do
            on(:invalid_scope) do
              flash.now[:error] = t(
                "projects.update_scope.select_a_scope",
                scope: "decidim.budgets.admin"
              )
            end

            on(:invalid_project_ids) do
              flash.now[:alert] = t(
                "projects.update_scope.select_a_project",
                scope: "decidim.budgets.admin"
              )
            end

            on(:update_projects_scope) do
              flash.now[:notice] = update_projects_bulk_response_successful(@response, :scope)
              flash.now[:alert] = update_projects_bulk_response_errored(@response, :scope)
            end
          end

          respond_to do |format|
            format.js { render :update_attribute, locals: { form_selector: "#js-form-scope-change-projects", attribute_selector: "#scope_id" } }
          end
        end

        def update_selected
          enforce_permission_to :update, :project_selected

          ::Decidim::Budgets::Admin::UpdateProjectSelection.call(params.dig(:selected, "value"), project_ids) do
            on(:invalid_selection) do
              flash.now[:error] = t(
                "projects.update_selected.select_a_selection",
                scope: "decidim.budgets.admin"
              )
            end

            on(:invalid_project_ids) do
              flash.now[:alert] = t(
                "projects.update_selected.select_a_project",
                scope: "decidim.budgets.admin"
              )
            end

            on(:update_projects_selection) do
              flash.now[:notice] = update_projects_bulk_response_successful(@response, :selected, selection: @selection)
              flash.now[:alert] = update_projects_bulk_response_errored(@response, :selected, selection: @selection)
            end
          end

          respond_to do |format|
            format.js { render :update_attribute, locals: { form_selector: "#js-form-change-selected-projects", attribute_selector: "#selected_value" } }
          end
        end

        def update_budget
          enforce_permission_to :update, :project, project: sample_project
          ::Decidim::Budgets::Admin::UpdateProjectsBudget.call(reference_budget, project_ids) do
            on(:invalid_project_ids) do
              flash.now[:alert] = t("projects.update_budget.select_a_project", scope: "decidim.budgets.admin")
            end

            on(:update_projects_budget) do
              moved_items(@response)
              flash.now[:notice] = update_projects_bulk_response_successful(@response, :budget)
              flash.now[:alert] = update_projects_bulk_response_errored(@response, :budget)
            end
          end

          respond_to do |format|
            format.js { render :update_attribute, locals: { form_selector: "#js-form-budget-change-projects", attribute_selector: "#selected_value", moved_items: } }
          end
        end

        private

        def projects
          @projects ||= filtered_collection
        end

        def orders
          @orders ||= Order.where(budget:)
        end

        def project_ids
          @project_ids ||= params[:project_ids]
        end

        def reference_budget
          return unless params[:reference_id]

          Budget.find(params[:reference_id])
        end

        def pending_orders
          orders.pending
        end

        def finished_orders
          orders.finished
        end

        def sample_project
          return if project_ids.empty?

          Decidim::Budgets::Project.find(project_ids.first)
        end

        def project
          @project ||= projects.find(params[:id])
        end

        def update_projects_bulk_response_successful(response, subject, extra = {})
          return if response[:successful].blank?

          interpolations = {
            subject_name: response[:subject_name],
            projects: response[:successful].to_sentence
          }

          case subject
          when :category
            t("projects.update_category.success", scope: "decidim.budgets.admin", **interpolations)
          when :scope
            t("projects.update_scope.success", scope: "decidim.budgets.admin", **interpolations)
          when :budget
            t("projects.update_budget.success", scope: "decidim.budgets.admin", **interpolations)
          when :selected
            if extra[:selection]
              t("projects.update_selected.success.selected", scope: "decidim.budgets.admin", **interpolations)
            else
              t("projects.update_selected.success.unselected", scope: "decidim.budgets.admin", **interpolations)
            end
          end
        end

        def update_projects_bulk_response_errored(response, subject, extra = {})
          return if response[:errored].blank?

          interpolations = {
            subject_name: response[:subject_name],
            projects: response[:errored].to_sentence
          }

          case subject
          when :category
            t("projects.update_category.invalid", scope: "decidim.budgets.admin", **interpolations)
          when :scope
            t("projects.update_scope.invalid", scope: "decidim.budgets.admin", **interpolations)
          when :budget
            t("projects.update_budget.invalid", scope: "decidim.budgets.admin", **interpolations)
          when :selected
            if extra[:selection]
              t("projects.update_selected.invalid.selected", scope: "decidim.budgets.admin", **interpolations)
            else
              t("projects.update_selected.invalid.unselected", scope: "decidim.budgets.admin", **interpolations)
            end
          end
        end

        def moved_items(response = nil)
          @moved_items ||= if response
                             @project_ids - response[:failed_ids]
                           else
                             @project_ids
                           end
        end
      end
    end
  end
end
