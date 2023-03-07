# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders metadata for an instance of a Project
    class ProjectMetadataCell < Decidim::CardMetadataCell
      include Decidim::Budgets::ProjectsHelper

      alias project model

      def initialize(*)
        super

        @items.prepend(*project_items)
      end

      private

      def project_items
        [voted_item, category_item, scope_item]
      end

      def show_votes_count?
        project.component.current_settings.show_votes?
      end

      def voted_item
        return unless show_votes_count? && model.confirmed_orders_count.positive?

        {
          cell: "decidim/budgets/project_votes_count",
          args: [model, { layout: :one_line }],
          icon: current_order_checked_out? && resource_added? ? "check-double-line" : "check-line"
        }
      end

      def current_order
        @current_order ||= controller.try(:current_order)
      end

      def resource_added?
        current_order && current_order.projects.include?(model)
      end

      def current_order_checked_out?
        current_order&.checked_out?
      end
    end
  end
end
