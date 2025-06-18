# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders a project
    class ProjectCell < Decidim::ViewModel
      include Decidim::Accountability::ApplicationHelper
      include Cell::ViewModel::Partial
      delegate :children, :milestone_entries, to: :model

      alias result model

      def show
        render template
      end

      def tab_panel_items
        [
          {
            enabled: ResultHistoryCell.new(result).render?,
            id: "included_history",
            text: t("decidim.history", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("history"),
            method: :cell,
            args: ["decidim/accountability/result_history", result]
          },
          {
            enabled: milestone_entries.any?,
            id: "milestone_entries",
            text: t("decidim.accountability.results.milestone.title"),
            icon: "route-line",
            method: :cell,
            args: ["decidim/accountability/project", result, { template: :milestone }]
          },
          {
            enabled: children.any?,
            id: "included_results",
            text: t("activemodel.attributes.result.subresults"),
            icon: "briefcase-2-line",
            method: :cell,
            args: ["decidim/accountability/results", result.children]
          }
        ] + attachments_tab_panel_items(result)
      end

      private

      def template
        @template ||= options[:template] || :show
      end

      def title
        decidim_escape_translated result.title
      end

      def description
        decidim_sanitize_admin translated_attribute(result.description)
      end
    end
  end
end
