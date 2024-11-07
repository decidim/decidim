# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the project resource so users can view them
    class ProjectsController < Decidim::Budgets::ApplicationController
      include FilterResource
      include NeedsCurrentOrder
      include Decidim::Budgets::Orderable
      include Decidim::IconHelper

      helper_method :projects, :project, :budget, :all_geocoded_projects, :tabs, :panels

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

      def tabs
        @tabs ||= items.map { |item| item.slice(:id, :text, :icon) }
      end

      def panels
        @panels ||= items.map { |item| item.slice(:id, :method, :args) }
      end

      def items
        @items ||= [
          {
            enabled: ProjectHistoryCell.new(@project).render?,
            id: "included_history",
            text: t("decidim.history", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("history"),
            method: :cell,
            args: ["decidim/budgets/project_history", @project]
          },
          {
            enabled: @project.photos.present?,
            id: "images",
            text: t("decidim.application.photos.photos"),
            icon: resource_type_icon_key("images"),
            method: :cell,
            args: ["decidim/images_panel", @project]
          },
          {
            enabled: @project.documents.present?,
            id: "documents",
            text: t("decidim.application.documents.documents"),
            icon: resource_type_icon_key("documents"),
            method: :cell,
            args: ["decidim/documents_panel", @project]
          }
        ].select { |item| item[:enabled] }
      end
    end
  end
end
