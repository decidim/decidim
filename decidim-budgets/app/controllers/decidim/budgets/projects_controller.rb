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
        budget.projects.includes([:scope, :component, :attachments, :category]).with_order(filter_params[:addition_type] == "added" ? current_order : nil)
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_status: default_filter_status_params,
          with_any_scope: nil,
          with_any_category: nil,
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
            enabled: @project.linked_resources(:proposals, "included_proposals").present?,
            id: "included_proposals",
            text: t("decidim/proposals/proposal", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("Decidim::Budgets::Project"),
            method: :cell,
            args: ["decidim/linked_resources_for", @project, { type: :proposals, link_name: "included_proposals" }]
          },
          {
            enabled: @project.linked_resources(:results, "included_projects").present?,
            id: "included_results",
            text: t("decidim/accountability/result", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("Decidim::Accountability::Result"),
            method: :cell,
            args: ["decidim/linked_resources_for", @project, { type: :results, link_name: "included_projects" }]
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
