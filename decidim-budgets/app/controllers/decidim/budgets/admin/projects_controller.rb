# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This controller allows an admin to manage projects from a Participatory Process
      class ProjectsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Proposals::Admin::Picker

        helper_method :projects, :finished_orders, :pending_orders, :present

        def new
          enforce_permission_to :create, :project
          @form = form(ProjectForm).from_params(
            attachment: form(AttachmentForm).instance
          )
        end

        def create
          enforce_permission_to :create, :project

          @form = form(ProjectForm).from_params(params, budget: budget)

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
          enforce_permission_to :update, :project, project: project
          @form = form(ProjectForm).from_model(project)
          @form.attachment = form(AttachmentForm).instance
        end

        def update
          enforce_permission_to :update, :project, project: project
          @form = form(ProjectForm).from_params(params, budget: budget)

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
          enforce_permission_to :destroy, :project, project: project

          DestroyProject.call(project, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("projects.destroy.success", scope: "decidim.budgets.admin")
              redirect_to budget_projects_path(budget)
            end
          end
        end

        private

        def projects
          @projects ||= budget.projects.page(params[:page]).per(15)
        end

        def orders
          @orders ||= Order.where(budget: budget)
        end

        def pending_orders
          orders.pending
        end

        def finished_orders
          orders.finished
        end

        def project
          @project ||= projects.find(params[:id])
        end
      end
    end
  end
end
