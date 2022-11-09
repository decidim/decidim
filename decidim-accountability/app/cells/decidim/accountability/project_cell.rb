# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders a project
    class ProjectCell < Decidim::ViewModel
      include ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      delegate :current_component, :component_settings, to: :controller
      delegate :children, :timeline_entries, to: :model

      alias result model

      def show
        render
      end

      private

      def title
        translated_attribute result.title
      end

      def description
        translated_attribute(result.description).html_safe
      end

      def scope
        current_scope.presence
      end

      def tabs
        tabs = []
        if children.any?
          tabs << { id: "list", text: t("decidim.accountability.results.timeline.title"), icon: "route-line" } if timeline_entries.any?
        else
          tabs << { id: "project_timeline", text: t("decidim.accountability.results.timeline.title"), icon: "route-line" } if timeline_entries.any?
          tabs += [
            { id: "included_proposals", text: t("activemodel.attributes.result.proposals"), icon: "chat-new-line" },
            { id: "included_projects", text: t("activemodel.attributes.result.project_ids"), icon: "git-pull-request-line" },
            { id: "included_meetings", text: t("activemodel.attributes.result.meetings_ids"), icon: "treasure-map-line" }
          ]
        end
        tabs
      end

      def panels
        panels = []
        if result.children.any?
          panels << { id: "list", method: :cell, args: ["decidim/accountability/results", result.children] }
        else
          panels << { id: "project_timeline", method: :render, args: [:timeline] } if timeline_entries.any?
          panels += [
            { id: "included_proposals", method: :cell, args: ["decidim/linked_resources_for", result, { type: :proposals, link_name: "included_proposals" }] },
            { id: "included_projects", method: :cell, args: ["decidim/linked_resources_for", result, { type: :projects, link_name: "included_projects" }] },
            { id: "included_meetings", method: :cell, args: ["decidim/linked_resources_for", result, { type: :meetings, link_name: "meetings_through_proposals" }] }
          ]
        end
        panels
      end

      def panel_contents
        @panel_contents ||= panels.each_with_object({}) do |panel, contents|
          contents[panel[:id]] = send(panel[:method], *panel[:args]).to_s.html_safe
        end.compact_blank
      end
    end
  end
end
