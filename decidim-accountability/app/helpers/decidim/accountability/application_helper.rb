# frozen_string_literal: true

module Decidim
  module Accountability
    # Custom helpers, scoped to the accountability engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::MapHelper

      def display_percentage(number)
        return if number.blank?

        number_to_percentage(number, precision: 1, strip_insignificant_zeros: true, locale: I18n.locale)
      end

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.accountability.name")
      end

      def apply_accountability_pack_tags
        append_stylesheet_pack_tag("decidim_accountability", media: "all")
        append_javascript_pack_tag("decidim_accountability")
      end
    end
  end
end
