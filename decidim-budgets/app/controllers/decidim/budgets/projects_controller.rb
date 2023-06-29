# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the project resource so users can view them
    class ProjectsController < Decidim::Budgets::ApplicationController
      include FilterResource
      include NeedsCurrentOrder
      include Decidim::Budgets::Orderable

      helper_method :projects, :project, :budget, :all_geocoded_projects

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
        @project ||= Project.find_by(id: params[:id])
      end

      def search_collection
        Project.where(budget:).includes([:scope, :component, :attachments, :category])
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_status: default_filter_status_params,
          with_any_scope: default_filter_scope_params,
          with_any_category: default_filter_category_params
        }
      end

      def default_filter_status_params
        show_selected_budgets? ? %w(selected) : %w(all)
      end

      def show_selected_budgets?
        voting_finished? && budget.projects.selected.any?
      end
    end
  end
end
