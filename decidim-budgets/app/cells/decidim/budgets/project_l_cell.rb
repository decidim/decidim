# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Budgets
    # This cell renders the List (:l) project card
    # for an instance of a Project
    class ProjectLCell < Decidim::CardLCell
      include Decidim::Budgets::ProjectsHelper

      alias project model

      private

      def resource_path
        if focus_mode?
          resource_locator([project.budget, "focus", project]).path(url_extra_params)
        else
          resource_locator([project.budget, project]).path(url_extra_params)
        end
      end

      def resource_added?
        current_order && current_order.projects.include?(model)
      end

      def current_order
        @current_order ||= controller.try(:current_order)
      end

      def focus_mode?
        options[:focus_mode]
      end

      def show_only_added
        options[:show_only_added]
      end

      def hide_vote_button?
        options[:hide_vote_button]
      end

      def resource_id = "project-#{project.id}-item"

      def metadata_cell = "decidim/budgets/project_metadata"
    end
  end
end
