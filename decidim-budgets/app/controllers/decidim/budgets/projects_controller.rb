# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the project resource so users can view them
    class ProjectsController < Decidim::Budgets::ApplicationController
      include FilterResource

      helper_method :projects, :project

      private

      def projects
        @projects ||= search.results.page(params[:page]).per(12)
      end

      def project
        @project ||= projects.find(params[:id])
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
        { feature: current_feature, organization: current_organization }
      end
    end
  end
end
