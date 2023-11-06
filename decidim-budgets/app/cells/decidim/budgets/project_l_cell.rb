# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Budgets
    # This cell renders the List (:l) project card
    # for an instance of a Project
    class ProjectLCell < Decidim::CardLCell
      include ActiveSupport::NumberHelper
      include Decidim::Budgets::ProjectsHelper

      alias project model

      private

      def resource_path
        resource_locator([project.budget, project]).path(url_extra_params)
      end

      def resource_added?
        current_order && current_order.projects.include?(model)
      end

      def current_order
        @current_order ||= controller.try(:current_order)
      end

      def show_only_added
        options[:show_only_added]
      end

      def resource_id = "project-#{project.id}-item"

      def metadata_cell = "decidim/budgets/project_metadata"
    end
  end
end
