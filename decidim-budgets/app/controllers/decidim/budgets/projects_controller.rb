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
          scope_id: "",
          category_id: ""
        }
      end

      def context_params
        { component: current_component, organization: current_organization }
      end
    end
  end
end
