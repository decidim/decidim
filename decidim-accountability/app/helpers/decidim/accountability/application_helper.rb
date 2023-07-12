# frozen_string_literal: true

module Decidim
  module Accountability
    # Custom helpers, scoped to the accountability engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper

      def display_percentage(number)
        return if number.blank?

        number_to_percentage(number, precision: 1, strip_insignificant_zeros: true, locale: I18n.locale)
      end

      def display_count(count)
        heading_parent_level_results(count)
      end

      def active_class_if_current(scope)
        "class=active" if scope.to_s == current_scope.to_s
      end

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.accountability.name")
      end

      def categories_label
        translated_attribute(component_settings.categories_label).presence || t("results.home.categories_label", scope: "decidim.accountability")
      end

      def subcategories_label
        translated_attribute(component_settings.subcategories_label).presence || t("results.home.subcategories_label", scope: "decidim.accountability")
      end

      def heading_parent_level_results(count)
        text = translated_attribute(component_settings.heading_parent_level_results).presence
        if text
          pluralize(count, text)
        else
          t("results.count.results_count", scope: "decidim.accountability", count:)
        end
      end

      def heading_leaf_level_results(count)
        text = translated_attribute(component_settings.heading_leaf_level_results).presence
        if text
          pluralize(count, text)
        else
          t("results.count.results_count", scope: "decidim.accountability", count:)
        end
      end

      def filter_items_for(participatory_space:, category:)
        [
          {
            url: url_for(filter: { with_category: category.try(:id) }),
            text: t("results.filters.all", scope: "decidim.accountability"),
            icon: "apps-2-line",
            active: current_scope.blank?,
            sr_text: Decidim::Scope.model_name.human(count: 2)
          },
          *(
            if participatory_space.scope
              [{
                url: url_for(filter: { with_scope: participatory_space.scope.id, with_category: category.try(:id) }),
                text: translated_attribute(participatory_space.scope.name),
                icon: resource_type_icon_key(participatory_space.scope.class),
                active: participatory_space.scope.id.to_s == current_scope.to_s,
                sr_text: Decidim::Scope.model_name.human(count: 1)
              }]
            end
          ),
          *participatory_space.subscopes.map do |scope|
            {
              url: url_for(filter: { with_scope: scope.id, with_category: category.try(:id) }),
              text: translated_attribute(scope.name),
              icon: resource_type_icon_key(scope.class),
              active: scope.id.to_s == current_scope.to_s,
              sr_text: Decidim::Scope.model_name.human(count: 1)
            }
          end
        ]
      end

      def apply_accountability_pack_tags
        append_stylesheet_pack_tag("decidim_accountability", media: "all")
        append_javascript_pack_tag("decidim_accountability")
      end
    end
  end
end
