# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the project resource so users can view them
    class ProjectsController < Decidim::Budgets::ApplicationController
      include FilterResource
      include NeedsCurrentOrder
      include Decidim::AttachmentsHelper
      include Decidim::Budgets::Orderable
      include Decidim::IconHelper

      helper_method :projects, :project, :budget, :all_geocoded_projects, :resource_added?, :tab_panel_items

      before_action :set_focus_mode_if_voting_open

      def index
        raise ActionController::RoutingError, "Not Found" unless budget
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless budget
        raise ActionController::RoutingError, "Not Found" unless project
      end

      private

      def budget
        @budget ||= Budget.where(component: current_component).includes(:projects).find_by(id: params[:budget_id])
      end

      def projects
        return @projects if @projects

        @projects = reorder(search.result)
        @projects = @projects.page(params[:page]).per(current_component.settings.projects_per_page)
      end

      def all_geocoded_projects
        @all_geocoded_projects ||= projects.geocoded
      end

      def project
        @project ||= budget&.projects&.find_by(id: params[:id])
      end

      def search_collection
        budget.projects.includes([:component, :attachments, :taxonomies]).with_order(filter_params[:addition_type] == "added" ? current_order : nil)
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_status: default_filter_status_params,
          with_any_taxonomies: nil,
          addition_type: "all"
        }
      end

      def default_filter_status_params
        show_selected_budgets? ? %w(selected) : %w(all)
      end

      def show_selected_budgets?
        voting_finished? && budget.projects.selected.any?
      end

      def tab_panel_items
        @tab_panel_items ||= [
          {
            enabled: ProjectHistoryCell.new(@project).render?,
            id: "included_history",
            text: t("decidim.history", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("history"),
            method: :cell,
            args: ["decidim/budgets/project_history", @project]
          },
          *attachments_tab_panel_items(@project)
        ].select { |item| item[:enabled] }
      end

      def add_breadcrumb_item
        return {} if project.blank?

        {
          label: translated_attribute(project.title),
          url: Decidim::EngineRouter.main_proxy(current_component).budget_project_url(budget, project, locale: current_locale),
          active: false,
          resource: project
        }
      end

      def add_parent_breadcrumb_item
        return {} if budget.blank?

        {
          label: translated_attribute(budget.title),
          url: Decidim::EngineRouter.main_proxy(current_component).budget_projects_url(budget, locale: current_locale),
          active: false,
          resource: budget
        }
      end
    end
  end
end
