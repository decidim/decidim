# frozen_string_literal: true

module Decidim
  module Accountability
    # Custom helpers, scoped to the meetings engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper

      def display_percentage(number)
        return if number.blank?

        number_to_percentage(number, precision: 1, strip_insignificant_zeros: true, locale: I18n.locale)
      end

      def display_count(count)
        heading_leaf_level_results(count)
      end

      def active_class_if_current(scope)
        %(class=active) if scope.to_s == current_scope.to_s
      end

      def categories_label
        translated_attribute(template_texts.categories_label).presence || t("results.home.categories_label", scope: "decidim.accountability")
      end

      def subcategories_label
        translated_attribute(template_texts.subcategories_label).presence || t("results.home.subcategories_label", scope: "decidim.accountability")
      end

      def heading_parent_level_results(count)
        if text = translated_attribute(template_texts.heading_parent_level_results).presence
          "#{count} #{text}"
        else
          t("results.count.results_count", scope: "decidim.accountability", count: count)
        end
      end

      def heading_leaf_level_results(count)
        if text = translated_attribute(template_texts.heading_leaf_level_results).presence
          "#{count} #{text}"
        else
          t("results.count.results_count", scope: "decidim.accountability", count: count)
        end
      end
    end
  end
end
