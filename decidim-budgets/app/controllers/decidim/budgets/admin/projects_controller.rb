# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This controller allows an admin to manage projects from a Participatory Process
      class ProjectsController < Admin::ApplicationController
        helper_method :projects, :finished_orders, :pending_orders

        def new
          enforce_permission_to :create, :project

          @form = form(ProjectForm).instance
        end

        def create
          enforce_permission_to :create, :project

          @form = form(ProjectForm).from_params(params)

          CreateProject.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("projects.create.success", scope: "decidim.budgets.admin")
              redirect_to projects_path
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
        end

        def update
          enforce_permission_to :update, :project, project: project

          @form = form(ProjectForm).from_params(params)

          UpdateProject.call(@form, project) do
            on(:ok) do
              flash[:notice] = I18n.t("projects.update.success", scope: "decidim.budgets.admin")
              redirect_to projects_path
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
              redirect_to projects_path
            end
          end
        end

        private

        def projects
          @projects ||= Project.where(component: current_component).page(params[:page]).per(15)
        end

        def orders
          @orders ||= Order.where(component: current_component)
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
