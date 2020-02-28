# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the project resource so users can view them
    class ProjectsController < Decidim::Budgets::ApplicationController
      include FilterResource
      include NeedsCurrentOrder
      include Orderable

      helper_method :projects, :project

      private

      def projects
        @projects ||= search.results.order_randomly(random_seed).page(params[:page]).per(current_component.settings.projects_per_page)
      end

      def project
        @project ||= search.results.find(params[:id])
      end

      def search_klass
        ProjectSearch
      end

      def default_filter_params
        {
          search_text: "",
          scope_id: default_filter_scope_params,
          category_id: default_filter_category_params
        }
      end

      def default_filter_category_params
        return "all" unless current_component.participatory_space.categories.any?

        ["all"] + current_component.participatory_space.categories.map { |category| category.id.to_s }
      end

      def default_filter_scope_params
        return "all" unless current_component.participatory_space.scopes.any?

        if current_component.participatory_space.scope
          ["all", current_component.participatory_space.scope.id] + current_component.participatory_space.scope.children.map { |scope| scope.id.to_s }
        else
          %w(all global) + current_component.participatory_space.scopes.map { |scope| scope.id.to_s }
        end
      end

      def context_params
        { component: current_component, organization: current_organization }
      end
    end
  end
end
