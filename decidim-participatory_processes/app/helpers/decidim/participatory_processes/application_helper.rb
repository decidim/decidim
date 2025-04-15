# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Custom helpers, scoped to the participatory processes engine.
    #
    module ApplicationHelper
      include Decidim::ResourceHelper
      include PaginateHelper

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.menu.processes")
      end

      def safe_content?
        rich_text_editor_in_public_views?
      end

      def render_rich_text(process, method)
        sanitized = render_sanitized_content(process, method, presenter_class: Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter)

        if safe_content?
          Decidim::ContentProcessor.render_without_format(sanitized).html_safe
        else
          Decidim::ContentProcessor.render(sanitized, "div")
        end
      end
    end
  end
end
