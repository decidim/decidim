# frozen_string_literal: true

module Decidim
  module Admin
    # Helper that provides methods related to Decidim::Admin::Filterable concern.
    module FilterableHelper
      # Renders the filters selector with tags in the admin panel.
      def admin_filter_selector
        render partial: "decidim/admin/shared/filters"
      end

      def filter_link_label(filter)
        link_to(i18n_filter_label(filter), href: "#")
      end

      def filter_link_value(filter, value)
        link_to(i18n_filter_value(filter, value), query_params_with(filter => value))
      end

      def i18n_filter_label(filter)
        t("decidim.admin.filters.#{filter}.label")
      end

      def i18n_filter_value(filter, value)
        t(value, scope: "decidim.admin.filters.#{filter}.values")
      rescue I18n::MissingTranslationData
        ""
      end

      def applied_filters_hidden_field_tags(*filters)
        html = []

        ransack_params.slice(*filters).each do |filter, value|
          html << hidden_field_tag("q[#{filter}]", value)
        end

        html << hidden_field_tag(:per_page, params[:per_page])

        html.join.html_safe
      end

      def applied_filters_tags(filters)
        html = []

        ransack_params.slice(*filters).each do |filter, value|
          html << applied_filter_tag(filter, value)
        end

        html.join.html_safe
      end

      def applied_filter_tag(filter, value)
        content_tag(:span, class: "label secondary") do
          tag = "#{i18n_filter_label(filter)}: "
          tag += i18n_filter_value(filter, value)
          tag += remove_filter_icon_link(filter)
          tag.html_safe
        end
      end

      def remove_filter_icon_link(filter)
        icon_link_to(
          "circle-x",
          url_for(query_params_without(filter)),
          t("decidim.admin.actions.cancel"),
          class: "action-icon--remove"
        )
      end
    end
  end
end
