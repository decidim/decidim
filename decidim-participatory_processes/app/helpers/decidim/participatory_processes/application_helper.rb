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
        true
      end

      def safe_content_admin?
        true
      end

      def render_rich_text(process, method)
        sanitized = render_sanitized_content(process, method, presenter_class: Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter)

        Decidim::ContentProcessor.render_without_format(sanitized).html_safe
      end
    end
  end
end
