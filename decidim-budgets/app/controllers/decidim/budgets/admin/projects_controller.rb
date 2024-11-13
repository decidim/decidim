# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This controller allows an admin to manage projects from a Participatory Process
      class ProjectsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Admin::ComponentTaxonomiesHelper
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
            { attachment: form(AttachmentForm).instance },
            budget:
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
          @form = form(ProjectForm).from_model(project, budget:)
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

          Decidim::Commands::DestroyResource.call(project, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("projects.destroy.success", scope: "decidim.budgets.admin")
              redirect_to budget_projects_path(budget)
            end
          end
        end

        def update_taxonomies
          enforce_permission_to :update, :project_taxonomy

          UpdateResourcesTaxonomies.call(params[:taxonomies], Decidim::Budgets::Project.where(id: project_ids), current_organization) do
            on(:invalid_taxonomies) do
              flash[:error] = I18n.t(
                "projects.update_taxonomies.select_a_taxonomy",
                scope: "decidim.budgets.admin"
              )
            end

            on(:invalid_resources) do
              flash[:alert] = I18n.t(
                "projects.update_taxonomies.select_a_project",
                scope: "decidim.budgets.admin"
              )
            end

            on(:update_resources_taxonomies) do |response|
              interpolations = {
                successful: response[:successful].map { |resource| decidim_escape_translated(resource.title) }.to_sentence,
                errored: response[:errored].map { |resource| decidim_escape_translated(resource.title) }.to_sentence,
                taxonomies: response[:taxonomies].map { |taxonomy| decidim_escape_translated(taxonomy.name) }.to_sentence
              }

              flash[:notice] = update_projects_bulk_response_successful(interpolations, :taxonomy) if response[:successful].any?
              flash[:alert] = update_projects_bulk_response_errored(interpolations, :taxonomy) if response[:errored].any?
            end
          end

          redirect_to budget_projects_path
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

            on(:update_projects_selection) do |response, selection|
              interpolations = {
                subject_name: response[:subject_name],
                successful: response[:successful].to_sentence,
                errored: response[:errored].to_sentence
              }

              flash.now[:notice] = update_projects_bulk_response_successful(interpolations, :selected, selection:) if response[:successful].any?
              flash.now[:alert] = update_projects_bulk_response_errored(interpolations, :selected, selection:) if response[:errored].any?
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

            on(:update_projects_budget) do |response|
              moved_items(response)
              interpolations = {
                subject_name: response[:subject_name],
                successful: response[:successful].to_sentence,
                errored: response[:errored].to_sentence
              }

              flash.now[:notice] = update_projects_bulk_response_successful(interpolations, :budget) if response[:successful].any?
              flash.now[:alert] = update_projects_bulk_response_errored(interpolations, :budget) if response[:errored].any?
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

        def update_projects_bulk_response_successful(interpolations, subject, extra = {})
          case subject
          when :taxonomy
            t("projects.update_taxonomies.success", scope: "decidim.budgets.admin", **interpolations)
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

        def update_projects_bulk_response_errored(interpolations, subject, extra = {})
          case subject
          when :taxonomy
            t("projects.update_taxonomies.invalid", scope: "decidim.budgets.admin", **interpolations)
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
