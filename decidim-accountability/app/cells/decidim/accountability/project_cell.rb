# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders a project
    class ProjectCell < Decidim::ViewModel
      include ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper
      include Decidim::AttachmentsHelper

      delegate :current_component, :component_settings, to: :controller
      delegate :children, :timeline_entries, to: :model

      alias result model

      def show
        render template
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

      def scope
        current_scope.presence
      end

      def tab_panel_items
        [
          {
            enabled: timeline_entries.any?,
            id: "timeline_entries",
            text: t("decidim.accountability.results.timeline.title"),
            icon: "route-line",
            method: :cell,
            args: ["decidim/accountability/project", result, { template: :timeline }]
          },
          {
            enabled: children.any?,
            id: "included_results",
            text: t("activemodel.attributes.result.subresults"),
            icon: "briefcase-2-line",
            method: :cell,
            args: ["decidim/accountability/results", result.children]
          },
          {
            enabled: result.linked_resources(:proposals, "included_proposals").present?,
            id: "included_proposals",
            text: t("activemodel.attributes.result.proposals"),
            icon: "chat-new-line",
            method: :cell,
            args: ["decidim/linked_resources_for", result, { type: :proposals, link_name: "included_proposals" }]
          },
          {
            enabled: result.linked_resources(:projects, "included_projects").present?,
            id: "included_projects",
            text: t("activemodel.attributes.result.project_ids"),
            icon: "git-pull-request-line",
            method: :cell,
            args: ["decidim/linked_resources_for", result, { type: :projects, link_name: "included_projects" }]
          },
          {
            enabled: result.linked_resources(:meetings, "meetings_through_proposals").present?,
            id: "included_meetings",
            text: t("activemodel.attributes.result.meetings_ids"),
            icon: "treasure-map-line",
            method: :cell,
            args: ["decidim/linked_resources_for", result, { type: :meetings, link_name: "meetings_through_proposals" }]
          }
        ] + attachments_tab_panel_items(result)
      end
    end
  end
end
