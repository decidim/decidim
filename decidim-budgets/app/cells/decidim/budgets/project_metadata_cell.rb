# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders metadata for an instance of a Project
    class ProjectMetadataCell < Decidim::CardMetadataCell
      include Decidim::Budgets::ProjectsHelper

      delegate :selected?, to: :model
      delegate :show_votes_count?, to: :controller

      alias project model

      def initialize(*)
        super

        @items.prepend(*project_items)
      end

      private

      def project_items
        taxonomy_items + [status_item] + [budget_amount]
      end

      def items_for_map
        ([voted_item_for_map] + taxonomy_items).compact_blank.map do |item|
          {
            text: item[:text].to_s.html_safe,
            icon: item[:icon].present? ? icon(item[:icon]).html_safe : nil
          }
        end
      end

      def voted_item_for_map
        {
          text: "#{model.confirmed_orders_count} #{t("decidim.budgets.projects.project.votes", count: model.confirmed_orders_count)}",
          icon: current_order_checked_out? && resource_added? ? "check-double-line" : "check-line"
        }
      end

      def status_item
        return unless controller.try(:voting_finished?) && selected?

        {
          cell: "decidim/budgets/project_selected_status",
          args: model
        }
      end

      def budget_amount
        return unless show_votes_count?

        {
          cell: "decidim/budgets/project_budget_amount",
          args: model,
          icon: "coin-line"
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
