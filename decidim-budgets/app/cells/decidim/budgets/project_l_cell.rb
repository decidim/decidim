# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Budgets
    # This cell renders the List (:l) project card
    # for an instance of a Project
    class ProjectLCell < Decidim::CardLCell
      include ActiveSupport::NumberHelper
      include Decidim::Budgets::ProjectsHelper

      delegate :current_order, to: :parent_controller

      alias project model

      private

      def resource_path
        resource_locator([project.budget, project]).path
      end

      def resource_added?
        current_order && current_order.projects.include?(model)
      end

      def resource_id = "project-#{project.id}-item"

      def metadata_cell = "decidim/budgets/project_metadata"
    end
  end
end
